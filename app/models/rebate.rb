class Rebate < ActiveRecord::Base

  has_paper_trail

  #
  # RELATIONS
  #
  belongs_to :gateway
  has_many   :provider_rebates, :inverse_of => :rebate
  has_many   :providers, :through => :provider_rebates

  accepts_nested_attributes_for :provider_rebates, :allow_destroy => true

  default_scope includes(:provider_rebates)

  scope :actual, lambda{ 
    where(arel_table[:start].lteq Date.today).
    where(arel_table[:finish].gteq Date.today)
  }

  scope :active, lambda{
    where(arel_table[:finish].gteq Date.today)
  }

  scope :outdated, lambda{
    where(arel_table[:finish].lteq Date.today)
  }

  #
  # VALIDATIONS
  #
  validates :gateway, :presence => true
  validates :start, :presence => true
  validates :finish, :presence => true
  validates :period_kind, :presence => true, :if => lambda{|x| !x.period_fee.blank?}

  validate do
    return if gateway.blank? || start.blank? || finish.blank?

    if start > finish
      errors.add(:start, :too_large)
      return
    end

    # Conditions intersections
    neighbors = self.class.where(:gateway_id => gateway_id)
    neighbors = neighbors.where("id != ?", id) unless id.blank?

    # Ranges intersections
    neighbors = neighbors.to_a

    neighbors.select! do |x| 
      x.start.between?(start, finish)    ||
      x.finish.between?(start, finish)   ||
      start.between?(x.start, x.finish)  ||
      finish.between?(x.start, x.finish)
    end

    if neighbors.count > 0
      errors[:base] << I18n.t('activerecord.errors.models.rebate.conditions_intersect')
    end
  end

  #
  # METHODS
  #
  def self.for(payment)
    rebate = payment.gateway.rebates.actual.first
    return nil if rebate.blank?

    rates = rebate.provider_rebates.
      by_provider(payment.provider).
      by_commission(payment.commission_amount).
      by_payment_type(payment.payment_type)
    rates.select{|x| 
      x.min <= payment.paid_amount && 
      x.max >= payment.paid_amount
    }.sort_by(&:weight).reverse.first
  end

  def title
    "##{id}"
  end
end