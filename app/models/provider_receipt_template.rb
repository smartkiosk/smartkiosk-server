class ProviderReceiptTemplate < ActiveRecord::Base
  has_many :providers, :conditions => "provider_receipt_template_id IS NOT NULL"
  accepts_nested_attributes_for :providers

  def self.base
    ProviderReceiptTemplate.where(:system => true).first
  end

  def self.sample
    ProviderReceiptTemplate.new :template => base.template
  end

  def self.for(payment)
    payment.provider.provider_receipt_template || base
  end

  def self.entities
    {
      :terminal => terminal_fields,
      :payment  => payment_fields,
      :provider => provider_fields
    }
  end

  def self.payment_fields
    [
      :id,
      :created_at,
      :paid_at,
      :foreign_id,
      :account,
      :fields,
      :paid_amount,
      :enrolled_amount,
      :commission_amount
    ]
  end

  def self.terminal_fields
    [
      :keyword,
      :address,
      :version
    ]
  end

  def self.provider_fields
    [
      :title,
      :keyword,
      :juristic_name,
      :inn,
      :support_phone
    ]
  end

  def self.masks
    %w(
      payment_paid_amount
      payment_enrolled_amount
      payment_commission_amount
      payment_paid_at
    )
  end

  def title
    providers.blank? ? "--" : providers.map{|x| x.title}.join(', ')
  end

  def compile(payment)
    data  = {}
    masks = self.class.masks

    self.class.entities.each do |entity, fields|
      fields.each do |field|
        model = (entity == :payment) ? payment : payment.send(entity)
        key   = "#{entity}_#{field}"

        data[key] = masks.include?(key) ? "{{ #{key} }}" : model.send(field)
      end
    end

    Liquid::Template.parse(template).render data
  end
end