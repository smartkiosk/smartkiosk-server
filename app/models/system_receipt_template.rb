class SystemReceiptTemplate < ActiveRecord::Base
  belongs_to :provider

  validates :template, :presence => true

  scope :new_from, lambda{|x|
    where(arel_table[:updated_at].gteq x)
  }

  def title
    I18n.t "smartkiosk.system_receipt_templates.#{keyword}"
  end
end