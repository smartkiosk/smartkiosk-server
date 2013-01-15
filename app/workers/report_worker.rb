class ReportWorker
  include Sidekiq::Worker

  def perform(report_id)
    Report.find(report_id).build!
  end
end