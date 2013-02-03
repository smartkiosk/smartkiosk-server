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
  def providers_dump(after=nil)
    providers = Provider.includes(:provider_fields).after(after)

    return [] if providers.blank?

    overload  = Hash[*terminal_profile.terminal_profile_providers.map{|x| [x.provider_id, x]}.flatten]

    providers.map do |x|
      icon = overload[x.id].icon rescue nil

      if icon.blank?
        icon = x.icon.try(:url)
      else
        icon = icon.url
      end

      {
        :id             => x.id,
        :title          => x.title,
        :keyword        => x.keyword,
        :icon           => icon,
        :priority       => overload[x.id].try(:priority),
        :fields         => x.fields_dump,
        :group_id       => x.provider_group_id,
        :requires_print => x.requires_print
      }
    end
  end

  def promotions_dump
    terminal_profile.terminal_profile_promotions.map{|x| x.provider_id}
  end

  def provider_groups_dump
    overload = Hash[*terminal_profile.terminal_profile_provider_groups.map{|x| [x.provider_group_id, x]}.flatten]

    ProviderGroup.all.map do |x|
      icon = overload[x.id].icon rescue nil

      if icon.blank?
        icon = x.icon.try(:url)
      else
        icon = icon.url
      end

      {
        :id        => x.id,
        :title     => x.title,
        :icon      => icon,
        :priority  => overload[x.id].try(:priority),
        :parent_id => x.provider_group_id
      }
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