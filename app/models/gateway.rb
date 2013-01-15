class Gateway < ActiveRecord::Base

  has_paper_trail

  #
  # RELATIONS
  #
  has_many :provider_gateways
  has_many :providers, :through => :provider_gateways
  has_many :payments, :order => 'id DESC'
  has_many :gateway_settings
  has_many :gateway_attachments
  has_many :gateway_switches
  has_many :rebates

  accepts_nested_attributes_for :gateway_settings
  accepts_nested_attributes_for :gateway_attachments
  accepts_nested_attributes_for :gateway_switches

  scope :enabled, where(:enabled => true)

  #
  # METHODS
  #
  def librarize(instantiate=true)
    klass = ("Payzilla::Gateways::"+payzilla.camelize).constantize
    return instantiate ? klass.new(self) : klass
  end

  def available_settings
    librarize(false)::available_settings
  end

  def available_attachments
    librarize(false)::available_attachments
  end

  def available_switches
    librarize(false)::available_switches
  end

  def serialize_options
    options = {}
    sources = {
      "setting" => available_settings, 
      "attachment" => available_attachments,
      "switch" => available_switches
    }

    sources.each do |prefix, source|
      source.each do |element|
        keyword = "#{prefix}_#{element}"
        options[keyword] = send keyword
      end
    end

    options
  end

  def respond_to?(key, include_private=false)
    return true if key.to_s.starts_with?('setting_') || key.to_s.starts_with?('attachment_') || key.to_s.starts_with?('switch_')
    super(key, include_private)
  end

  def method_missing(name, *args, &block)
    assign = name[-1] == '='
    name   = name[0, name.length-1] if assign

    if name.to_s.starts_with?('setting_')
      source = gateway_settings
      klass  = GatewaySetting
      name   = name.to_s.gsub('setting_', '')
    elsif name.to_s.starts_with?('attachment_')
      source = gateway_attachments
      klass  = GatewayAttachment
      name   = name.to_s.gsub('attachment_', '')
    elsif name.to_s.starts_with?('switch_')
      source = gateway_switches
      klass  = GatewaySwitch
      name   = name.to_s.gsub('switch_', '')
    else
      return super
    end

    if assign
      data = source.select{|x| x.keyword == name}.first

      if data.blank?
        source << klass.new(:keyword => name, :gateway_id => id, :value => args[0])
      else
        data.value = args[0]
      end
    else
      result = source.select{|x| x.keyword == name}.first.try(:value)
      result = false if result.blank? && klass == GatewaySwitch
      result
    end
  end
end
