  class Collection < ActiveRecord::Base
  include DateExpander

  expand_date_from :collected_at

  has_paper_trail

  SOURCE_INNER  = 0
  SOURCE_IMPORT = 1

  #
  # RELATIONS
  #
  belongs_to :terminal
  belongs_to :agent

  #
  # VALIDATIONS
  #
  validates :terminal, :presence => true, :if => lambda{|x| x.source == SOURCE_INNER }
  validates :agent, :presence => true, :if => lambda{|x| x.source == SOURCE_INNER }
  validates :collected_at, :presence => true

  validate do
    errors.add(:session_ids, :not_an_array) unless session_ids.is_a?(Array)
    errors.add(:banknotes, :not_a_hash) unless banknotes.is_a?(Hash)
  end

  #
  # MODIFICATIONS
  #
  serialize :banknotes, JSON
  serialize :session_ids, JSON

  before_validation do
    self.agent = terminal.agent unless terminal.blank?
    self.session_ids ||= []
    self.banknotes ||= {}

    return unless session_ids.is_a?(Array)
    return unless banknotes.is_a?(Hash)

    payments = Payment.where(:session_id => session_ids)

    self.cash_sum = banknotes.collect{|k,v| k.to_i*v.to_i}.sum
    self.payments_sum = payments.map{|x| x.paid_amount || 0}.sum
    self.payments_count = session_ids.count
    self.approved_payments_sum = payments.select{|x| x.approved?}.map{|x| x.paid_amount || 0}.sum
    self.approved_payments_count = payments.select{|x| x.approved?}.count
    self.cash_payments_count = payments.select{|x| !x.cashless?}.count
    self.cashless_payments_count = payments.select{|x| x.cashless?}.count
  end

  after_create do
    unless terminal.blank?
      if terminal.collected_at.blank? || self.collected_at > terminal.collected_at
        terminal.update_attribute(:collected_at, self.collected_at)
      end
    end

    unless session_ids.blank?
      Payment.where(:foreign_id => session_ids).update_all(:collection_id => id)
    end
  end
end
