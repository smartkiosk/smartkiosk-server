class ReviseWorker
  include Sidekiq::Worker

  def perform(revision_id)
    Revision.find(revision_id).perform!
  end
end