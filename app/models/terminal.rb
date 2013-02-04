require_dependency 'terminal_ping'

class Terminal < ActiveRecord::Base
  include Redis::Objects::RMap

  HARDWARE = %w(cash_acceptor modem printer)
  ORDERS   = %w(reload reboot disable enable upgrade)

  has_rmap({:id => lambda{|x| x.to_s}}, :keyword)
  has_paper_trail :ignore => [:incomplete_orders_count]

  #
  # RELATIONS
  #
  belongs_to :terminal_profile
  belongs_to :agent
  has_many :collections, :order => 'id DESC'
  has_many :payments, :order => 'id DESC'
  has_many :terminal_orders, :order => 'id DESC'

  list :pings, :marshal => true, :maxlength => 480

  scope :ok,      where(:condition => 'ok')
  scope :warning, where(:condition => 'warning')
  scope :error,   where(:condition => 'error')

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
      :version     => data.version
    }

    HARDWARE.each do |device|
      update["#{device}_error"] = data.error(device)
    end

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