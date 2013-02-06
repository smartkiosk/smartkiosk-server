class GemStashUpdateWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false

  def perform
    begin
      TerminalBuild.stash_worker_lock.lock do
        while TerminalBuild.stash_counter.getset(0) > 0
          update_stash!
        end
      end
    rescue Redis::Lock::LockTimeout => e
      Sidekiq::Logging.logger.warn "Lock timeout."

      # To avoid excessive cpu burning but still ensure robust updates
      GemStashUpdateWorker.perform_in 1.minute
    end
  end

  def update_stash!
    builds = TerminalBuild.all

    stasher = GemStasher.new Sidekiq::Logging.logger, Rails.root.join("public/gems")
    stasher.maintain_cache builds.map(&:path)
    stasher.update_index

    TerminalBuild.transaction do
      builds.each do |build|
        begin
          build.gems_ready = true

          build.save!
        rescue => e
          Sidekiq::Logging.logger.warn "error occured during update of build #{build.id}: #{e}"
        end
      end
    end

  end
end
