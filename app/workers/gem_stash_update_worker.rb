class GemStashUpdateWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false

  SEMAPHORE = ConnectionPool.new(:size => 1, :timeout => 5) { true }

  def perform
    begin
      SEMAPHORE.with do |glory|
        builds = TerminalBuild.all

        stasher = GemStasher.new Sidekiq::Logging.logger, Rails.root.join("public/gems")
        stasher.maintain_cache builds.map(&:path)
        stasher.update_index

        TerminalBuild.transaction do
          builds.each { |build| build.update_attribute :gems_ready, true }
        end

        nil
      end
    rescue Timeout::Error => e
      Sidekiq::Logging.logger.warn "Semaphore timeout. #{e.to_s}"
    end
  end
end
