require "bundler"
require "rubygems/user_interaction"
require "rubygems/package"
require "net/http"
require "set"
require "fileutils"

# Make LazySpecification Set-able
class Bundler::LazySpecification
  alias :eql? :==

  def hash
    [ @name, @version, @dependencies, @platform, @source ].hash
  end
end

class GemStasher
  def initialize(logger, gempath)
    @logger = logger
    @gempath = gempath
  end

  def maintain_cache(builds)
    sources = Set.new
    required_gems = Set.new
    existing_gems = Set.new

    FileUtils.mkdir_p "#{@gempath}/gems"

    @logger.info "Updating gem cache"

    Dir["#{@gempath}/gems/*.gem"].each do |gempack|
      begin
        File.open(gempack) do |io|
          Gem::Package.open(io, 'r', nil) do |gem|
            spec = Bundler::LazySpecification.new(
              gem.metadata.name,
              gem.metadata.version,
              gem.metadata.platform
            )

            existing_gems.add spec
          end
        end
      rescue => e
        @logger.warn "unable to read #{gempack}: #{e}"
        File.delete gempack
      end
    end

    builds.each do |build|
      begin
        gemfile = Bundler::Definition.build File.join(build, "Gemfile"),
                                        File.join(build, "Gemfile.lock"), {}

        gemfile.sources.each do |source|
          next unless source.kind_of? Bundler::Source::Rubygems

          source.remotes.each { |remote| sources.add remote }
        end

        gemfile.resolve.each do |spec|

          required_gems.add Bundler::LazySpecification.new(
            spec.name,
            spec.version,
            spec.platform
          )
        end
      rescue => e
        @logger.warn "unable to process #{build}: #{e}"
      end
    end

    dead_gems    = existing_gems - required_gems
    missing_gems = required_gems - existing_gems

    dead_gems.each do |spec|
      @logger.info "- deleting dead #{spec.name} #{spec.version}"

      filename = filename_for_spec spec

      begin
        File.delete "#{@gempath}/#{filename}"
      rescue => e
        @logger.warn "unable to delete #{filename}: #{e}"
      end
    end

    if missing_gems.any?
      sources.each do |uri|
        fetcher = Bundler::Fetcher.new uri

        names = missing_gems.map { |gem| gem.name }
        specs = fetcher.specs names, uri

        missing_gems.each do |gem|
          found = specs.local_search gem

          next unless found.any?

          missing_gems.delete gem

          spec, = found
          filename = filename_for_spec spec
          local_file_name = "#{@gempath}/#{filename}"

          file_uri = uri.dup
          file_uri.path = "#{uri.path}#{filename}"

          @logger.info " - fetching #{spec.name} #{spec.version} from #{uri}"

          io = File.open(local_file_name, "wb")
          begin
            fetch_file file_uri, io
          rescue => e
            File.delete io
            warn "unable to download #{filename}: #{e}"
          ensure
            io.close
          end
        end
      end

      if missing_gems.any?
        @logger.warn "unresolved dependencies:"
        missing_gems.each do |spec|
          @logger.warn " - #{spec}"
        end
      end
    end
  end

  def update_index
    @logger.info "Updating gem index at #{@gempath}"
    # unfortunately, it's not possible to use Gem::Index without breaking
    # host application bundler.
    Bundler.with_clean_env do
      system "gem", "generate_index", "--directory", @gempath.to_s, "--quiet"
    end
  end

  private

  def filename_for_spec(spec)
    "gems/#{spec.name}-#{spec.version}.gem"
  end

  def fetch_file(uri, io)
    Net::HTTP.start(uri.host,
                    uri.port,
                    :use_ssl => uri.scheme == 'https',
                    :verify_mode => OpenSSL::SSL::VERIFY_NONE
                   ) do |http|
      http.request_get(uri.path) do |response|
        case response
        when Net::HTTPSuccess
          response.read_body { |chunk| io.write chunk }

        when Net::HTTPRedirection
          fetch_file URI.join(uri.to_s, response['location']), io

        else
          raise response.value
        end
      end
    end
  end
end

Bundler.settings[:frozen] = true
