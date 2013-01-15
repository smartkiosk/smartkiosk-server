require 'string_file'

class Revision < ActiveRecord::Base
  include Redis::Objects
  include Stateflow

  #
  # STATEFLOW
  #
  stateflow do
    initial :new

    state :new, :queue, :done, :error

    event :enqueue do
      transitions :from => [:error, :new], :to => :queue, :if => :moderated?
      transitions :from => :new, :to => :new
    end

    event :perform do
      transitions :from => :queue, :to => [:done, :error], :decide => :perform?
    end
  end

  def enqueue!
    enqueue
    save!
    ReviseWorker.perform_async(id)
  end

  #
  # RELATIONS
  #
  belongs_to :gateway
  has_many :payments, :dependent => :nullify

  mount_uploader :data, FileUploader

  scope :unmoderated, where(:moderated => false)
  scope :error, where(:state => 'error')

  #
  # VALIDATIONS
  #
  validates :gateway, :presence => true
  validates :date, :uniqueness => {:scope => :gateway_id}

  #
  # MODIFICATIONS
  #
  after_create do
    # This is `after_create` cause sometimes we have to have the ID of revision at Payzilla
    # Also we require the id of revision to attach payments

    start  = date.to_datetime.change(:hour => 0)
    finish = start + 1.day - 1.second

    @payments = Payment.where(:gateway_id => gateway.id, :paid_at => start..finish)

    @payments.update_all(:revision_id => self.id)

    sum_query = @payments.arel; sum_query.projections = []
    sum_query = sum_query.project(Payment.arel_table[:paid_amount].sum.as("paid"))
    sum_query = sum_query.project(Payment.arel_table[:enrolled_amount].sum.as("enrolled"))
    sum_query = connection.select_all(sum_query.to_sql).first

    self.payments_count = @payments.count
    self.paid_sum       = sum_query['paid'] || 0
    self.enrolled_sum   = sum_query['enrolled'] || 0
    self.commission_sum = self.paid_sum - self.enrolled_sum
    self.moderated      = !gateway.requires_revisions_moderation

    data = gateway.librarize.generate_revision(self)
    self.data = StringFile.new("data.#{data[0]}", data[1])

    enqueue if moderated?

    save!
  end

  #
  # METHODS
  #
  def title
    "#{gateway.title}: #{I18n.l date}"
  end

  def moderate!
    return if moderated?
    update_attribute(:moderated, true)
    enqueue!
  end

  def perform?
    result = gateway.librarize.send_revision(self, data.read)

    if result[:success]
      return :done
    else
      self.update_attribute(:error, result[:error])
      return :error
    end
  end
end
