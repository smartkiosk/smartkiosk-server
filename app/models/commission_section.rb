class CommissionSection < ActiveRecord::Base

  #
  # RELATIONS
  #
  belongs_to :commission, :inverse_of => :commission_sections
  belongs_to :agent
  belongs_to :terminal

  scope :by_terminal, lambda { |x|
    conditions = [
      '(terminal_id IS NULL AND agent_id IS NULL)',
      '(agent_id = ? AND terminal_id IS NULL)',
      'terminal_id = ?'
    ]
    where(
      conditions.join(' OR '),
      x.agent_id,
      x.id
    )
  }
  scope :by_payment_type, lambda { |x|
    where("payment_type IS NULL OR payment_type = ?", x)
  }

  #
  # VALIDATIONS
  #
  validates :min, :presence => true
  validates :max, :presence => true

  validate do
    return if min.blank? || max.blank?

    if min > max
      errors.add(:min, :too_large)
      return
    end

    neighbors = commission.commission_sections.select{|x| x != self}

    if neighbors.select{|x| x.payment_type.nil? != payment_type.nil?}.count > 0
      errors[:base] << I18n.t('activerecord.errors.models.commission.payment_type_intersects')
    end

    neighbors.select!{|x| x.agent_id == agent_id && x.terminal_id == terminal_id}

    neighbors.select! do |x| 
      x.min.between?(min, max)   ||
      x.max.between?(min, max)   ||
      min.between?(x.min, x.max) ||
      max.between?(x.min, x.max)
    end

    if neighbors.count > 0
      errors[:base] << I18n.t('activerecord.errors.models.commission.conditions_intersect')
    end
  end

  def weight
    return 3 unless terminal_id.blank?
    return 2 unless agent_id.blank?
    return 1
  end

  def fee(amount)
    (self.static_fee||0) + amount*(self.percent_fee||0)/100
  end
end
