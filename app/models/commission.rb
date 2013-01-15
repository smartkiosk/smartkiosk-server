class Commission < ActiveRecord::Base

  has_paper_trail

  #
  # RELATIONS
  #
  belongs_to :provider_profile
  has_many :providers, :through => :provider_profile
  has_many :commission_sections, :inverse_of => :commission

  accepts_nested_attributes_for :commission_sections, :allow_destroy => true

  default_scope includes(:commission_sections)

  scope :actual, lambda{ 
    where(arel_table[:start].lteq Date.today).
    where(arel_table[:finish].gteq Date.today)
  }

  #
  # VALIDATIONS
  #
  validates :provider_profile, :presence => true
  validates :start, :presence => true
  validates :finish, :presence => true

  validate do
    return if start.blank? || finish.blank?

    if start > finish
      errors.add(:start, :too_large)
      return
    end

    # Conditions intersections
    neighbors = self.class.where(:provider_profile_id => provider_profile_id)
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
      errors[:base] << I18n.t('activerecord.errors.models.commission.conditions_intersect')
    end
  end

  #
  # METHODS
  #
  def self.for(payment, filter_amount=true)
    commission = payment.provider.commissions.actual.first
    return [] if commission.blank?

    rates = commission.commission_sections.
      by_terminal(payment.terminal).
      by_payment_type(payment.payment_type)

    rates.select!{|x| 
      x.min <= payment.paid_amount && 
      x.max >= payment.paid_amount
    } if filter_amount

    rates.sort_by(&:weight).reverse
  end

  def title
    "##{id}"
  end
end