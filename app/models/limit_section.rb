class LimitSection < ActiveRecord::Base

  #
  # RELATIONS
  #
  belongs_to :limit, :inverse_of => :limit_sections
  belongs_to :agent
  belongs_to :terminal_profile

  scope :by_terminal_profile_and_agent_ids, lambda { |p, a|
    conditions = [
      '(terminal_profile_id IS NULL AND agent_id IS NULL)',
      '(agent_id = ? AND terminal_profile_id IS NULL)',
      'terminal_profile_id = ?'
    ]
    where(
      conditions.join(' OR '),
      a,
      p
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

    neighbors = limit.limit_sections.select{|x| x != self}

    if neighbors.select{|x| x.payment_type.nil? != payment_type.nil?}.count > 0
      errors[:base] << I18n.t('activerecord.errors.models.limit.payment_type_intersects')
    end

    neighbors.select!{|x| x.agent_id == agent_id && x.terminal_profile_id == terminal_profile_id}

    if neighbors.count > 0
      errors[:base] << I18n.t('activerecord.errors.models.limit.conditions_intersect')
    end
  end

  def weight
    return 3 unless terminal_profile_id.blank?
    return 2 unless agent_id.blank?
    return 1
  end
end
