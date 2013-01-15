class Report < ActiveRecord::Base
  include Stateflow

  #
  # STATEFLOW
  #
  stateflow do
    initial :new

    state :new, :queue, :done, :error

    event :enqueue do
      transitions :from => [:error, :new, :done], :to => :queue
    end

    event :build do
      transitions :from => :queue, :to => [:done, :error], :decide => :build?
    end
  end

  def enqueue!
    enqueue
    save!
    ReportWorker.perform_async(id)
  end

  #
  # RELATIONS
  #
  belongs_to :report_template
  belongs_to :user
  has_many :report_results, :order => 'id DESC'

  #
  # VALIDATIONS
  #
  validates :report_template, :presence => true
  validates :user, :presence => true
  validates :start, :presence => true, :if => lambda{|x| x.report_builder.try(:requires_dates?)}
  validates :finish, :presence => true, :if => lambda{|x| x.report_builder.try(:requires_dates?)}

  #
  # MODIFICATIONS
  #
  after_create :enqueue!

  #
  # METHODS
  #
  def title
    "##{id} (#{report_template.title})"
  end

  def report_builder
    return nil if report_template.blank?
    @report_builder ||= report_template.report_builder(self)
  end

  def build?
    query  = report_builder.query

    begin
      data = ActiveRecord::Base.connection.exec_query(query).to_hash
      ReportResult.create! :report_id => id, :rows => data.length, :data => data
      return :done
    rescue Exception => e
      update_attribute :error, e.to_s
      return :error
    end
  end
end
