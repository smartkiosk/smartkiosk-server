class TerminalOrder < ActiveRecord::Base

  has_paper_trail

  belongs_to :terminal

  scope :unsent, where(:state => 'new')
  scope :incomplete, where("state != ?", 'complete')

  validates :terminal, :presence => true

  serialize :args

  after_save do
    terminal.update_attribute :incomplete_orders_count,
      terminal.terminal_orders.incomplete.count
  end

  def title
    I18n.t "smartkiosk.terminal_orders.#{keyword}"
  end

  def error?
    !error.blank?
  end

  def sent?
    state == 'sent'
  end

  def complete?
    state == 'complete'
  end

  def sent!(percent=nil, error=nil)
    update_attributes(:state => (complete? ? 'complete' : 'sent'), :percent => [percent.to_i, self.percent.to_i].max, :error => error)
  end

  def complete!
    update_attribute(:state, 'complete')
  end
end
