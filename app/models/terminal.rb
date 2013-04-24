require_dependency 'monitorer'
require_dependency 'terminal_ping'

class Terminal < ActiveRecord::Base
  include Redis::Objects::RMap

  HARDWARE = %w(cash_acceptor modem printer card_reader watchdog)
  ORDERS   = %w(reload reboot disable enable upgrade)

  has_rmap({:id => lambda{|x| x.to_s}}, :keyword)
  has_paper_trail :ignore => [:incomplete_orders_count]

  after_save do
    Monitorer.notify Hash[*changed.map{|x| [x, send(x)]}.flatten].merge(:id => id)
  end

  #
  # RELATIONS
  #
  serialize :banknotes, JSON

  belongs_to :terminal_profile
  belongs_to :agent
  has_many :collections, :order => 'id DESC'
  has_many :payments, :order => 'id DESC'
  has_many :terminal_orders, :order => 'id DESC'
  has_many :session_records, :order => 'created_at DESC'

  list :pings, :marshal => true, :maxlength => 480

  scope :ok,      where(:condition => 'ok')
  scope :warning, where(:condition => 'warning')
  scope :error,   where(:condition => 'error')

  delegate :title, :to => :agent, :prefix => true

  #
  # VALIDATIONS
  #
  validates :terminal_profile, :presence => true
  validates :title, :presence => true
  validates :keyword, :presence => true, :uniqueness => true
  validates :agent, :presence => true

  #
  # METHODS
  #
  def self.as_hash(fields)
    connection.select_all(select(fields).arel).each do |attrs|
      yield(attrs) if block_given?
    end
  end

  def title
    keyword
  end

  def ping!(data)
    raise ActiveRecord::RecordInvalid unless data.valid?
    pings.unshift data

    update = {
      :state       => data.state,
      :condition   => data.condition,
      :notified_at => data.created_at,
      :version     => data.version,
      :banknotes   => data.banknotes,
      :cash        => data.cash,
      :cashless    => data.cashless,
      :ip          => data.ip,
    }

    HARDWARE.each do |device|
      update["#{device}_error"] = data.error(device)
      update["#{device}_model"] = data.value('model', device)
      update["#{device}_version"] = data.value('version', device)
    end

    update["modem_signal_level"] = data.value('signal_level', 'modem')
    update["modem_balance"] = data.value('balance', 'modem')

    if data.ok?
      update[:issues_started_at] = nil
    else
      update[:issues_started_at] = DateTime.now if issues_started_at.blank?
    end

    self.without_versioning do
      update_attributes update
    end
  end

  def order!(keyword, *args)
    TerminalOrder.create!(:terminal_id => id, :keyword => keyword, :args => args)
  end
end