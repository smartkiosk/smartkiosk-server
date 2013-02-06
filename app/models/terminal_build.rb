require 'digest/md5'

class TerminalBuild < ActiveRecord::Base
  include Redis::Objects

  lock :stash_worker, :global => true, :timeout => 0.1
  counter :stash_counter, :global => true

  mount_uploader :source, ZipUploader

  validates :source, :presence => true
  serialize :hashes

  validate do
    errors[:base] << I18n.t('activerecord.errors.models.terminal_build.no_version') if version.blank?
  end

  before_validation do
    self.version = read_version
  end

  after_create do
    Zip::ZipFile.open(source.path) do |zip_file|
      zip_file.each do |f|
        destination = File.join(self.path, f.name)
        FileUtils.mkdir_p File.dirname(destination)
        zip_file.extract(f, destination) unless File.exist?(destination)
      end
    end

    self.update_attributes :hashes => build_hashes
    update_stash
  end

  after_destroy do
    FileUtils.rm_rf path
    update_stash
  end

  def path
    Rails.root.join("public/builds/#{id}").to_s
  end

  def url
    "/builds/#{id}"
  end

  def read_version
    return unless source.present?

    Zip::ZipFile.open(source.path) do |zip_file|
      return zip_file.read('VERSION').strip rescue nil
    end
  end

  def build_hashes
    files  = Dir.glob("#{path}/**/**", File::FNM_DOTMATCH).select{|x| File.file? x}.map!{|x| x.gsub path+'/', ''}
    hashes = {}

    files.each do |file|
      hashes[file] = [
        Digest::MD5.file("#{path}/#{file}").hexdigest,
        File.size?("#{path}/#{file}")
      ]
    end

    hashes
  end

  protected

  def update_stash
    TerminalBuild.stash_counter.incr

    GemStashUpdateWorker.perform_async
  end
end
