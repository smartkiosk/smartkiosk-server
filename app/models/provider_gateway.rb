class ProviderGateway < ActiveRecord::Base
  #
  # RELATIONS
  #
  belongs_to :provider, :counter_cache => true
  belongs_to :gateway

  scope :enabled, includes(:gateway).where(:gateways => {:enabled => true})

  #
  # MODIFICATIONS
  #
  serialize :fields_mapping

  #
  # METHODS
  #
  def human_fields_mapping=(value)
    self.fields_mapping = value.gsub("\r", '').split("\n").map{|x| x.split('=')}
    self.fields_mapping = Hash[*self.fields_mapping.select{|x| x.length > 1}.flatten]
  end

  def human_fields_mapping
    return '' if self.fields_mapping.blank?
    self.fields_mapping.collect{|k,v| "#{k}=#{v}"}.join("\n")
  end

  def map(account, raw_fields)
    fields = {}

    if !account.blank? && !account_mapping.blank?
      fields[account_mapping] = account
    end

    unless raw_fields.blank?
      unless fields_mapping.blank?
        fields_mapping.each do |k, v|
          fields[v] = raw_fields[k] unless raw_fields[k].blank?
        end
      else
        fields.merge!(raw_fields)
      end
    end

    fields
  end
end
