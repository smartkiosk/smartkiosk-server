class ProviderRebate < ActiveRecord::Base
  belongs_to :rebate, :inverse_of => :provider_rebates
  belongs_to :provider

  scope :by_provider, lambda { |x|
    if x.blank?
      where(:provider_id => nil)
    else
      where("provider_id IS NULL OR provider_id = ?", x.id)
    end
  }
  scope :by_commission, lambda { |x|
    where("requires_commission IS NULL OR requires_commission = ?", !x.blank?)
  }
  scope :by_payment_type, lambda { |x|
    where("payment_type IS NULL OR payment_type = ?", x)
  }

  validates :rebate, :presence => true
  validates :provider, :presence => true
  validates :min, :presence => true
  validates :max, :presence => true
  validates :min_percent_amount, :presence => true

  validate do
    return if min.blank? || max.blank?

    if min > max
      errors.add(:min, :too_large)
      return
    end

    # Conditions intersections
    neighbors = rebate.provider_rebates.select{|x| x != self}

    if neighbors.select{|x| x.requires_commission.nil? != requires_commission.nil?}.count > 0
      errors[:base] << I18n.t('activerecord.errors.models.rebate.requires_commission_intersects')
    end

    if neighbors.select{|x| x.payment_type.nil? != payment_type.nil?}.count > 0
      errors[:base] << I18n.t('activerecord.errors.models.rebate.payment_type_intersects')
    end

    # Ranges intersections
    neighbors.select!{|x| x.provider_id == provider_id}

    neighbors.select! do |x| 
      x.min.between?(min, max)   ||
      x.max.between?(min, max)   ||
      min.between?(x.min, x.max) ||
      max.between?(x.min, x.max)
    end

    if neighbors.length > 0
      errors[:base] << I18n.t('activerecord.errors.models.rebate.conditions_intersect')
    end
  end

  def weight
    return 2 unless provider_id.blank?
    return 1
  end

  def fee(amount)
    percent_amount = amount*(self.percent_fee||0)/100
    percent_amount = [percent, min_percent_amount].min
    (self.static_fee||0) + percent_amount
  end
end
