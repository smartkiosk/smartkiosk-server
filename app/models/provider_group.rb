class ProviderGroup < ActiveRecord::Base
  include Redis::Objects

  mount_uploader :icon, IconUploader

  value :timestamp, :global => true, :marshal => true

  after_save do
    self.class.timestamp = updated_at
  end

  after_destroy do
    self.class.timestamp = DateTime.now
  end

  belongs_to :provider_group
  has_many :provider_groups, :order => :title
  has_many :providers, :order => :priority
  has_many :terminal_profile_provider_groups, :dependent => :destroy

  accepts_nested_attributes_for :providers

  validates :title, :presence => true

  def self.tree(exclude=nil)
    result = {}

    inject = lambda{|result, exclude, entry, level|
      unless entry == exclude
        result["#{'--'*level}#{' ' if level > 0}#{entry.title}"] = entry.id

        entry.provider_groups.each do |x|
          inject.call(result, exclude, x, level+1)
        end
      end
    }

    ProviderGroup.where(:provider_group_id => nil).order(:title).
      select{|x| x.provider_group.blank?}.each do |x|
        inject.call(result, exclude, x, 0)
      end

    result
  end
end
