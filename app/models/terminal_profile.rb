class TerminalProfile < ActiveRecord::Base
  include Redis::Objects::RMap

  has_rmap({:id => lambda{|x| x.to_s}}, :title)
  has_paper_trail

  value :cached_providers
  value :cached_providers_timestamp, :marshal => true
  lock  :cached_providers, :expiration => 15

  has_many :terminals, :conditions => "terminal_profile_id IS NOT NULL"
  has_many :terminal_profile_promotions, :dependent => :destroy, :order => :priority
  has_many :terminal_profile_providers, :dependent => :destroy, :order => :priority
  has_many :terminal_profile_provider_groups, :dependent => :destroy, :order => :priority

  mount_uploader :logo, FileUploader

  accepts_nested_attributes_for :terminal_profile_promotions, :allow_destroy => true
  accepts_nested_attributes_for :terminal_profile_providers
  accepts_nested_attributes_for :terminal_profile_provider_groups

  validates :title, :presence => true, :uniqueness => true

  def actualize_links!
    ProviderGroup.where(ProviderGroup.arel_table[:id].not_in TerminalProfileProviderGroup.arel_table.project(:provider_group_id)).each do |pg|
      terminal_profile_provider_groups << TerminalProfileProviderGroup.new(:provider_group_id => pg.id, :terminal_profile_id => id)
    end

    Provider.where(Provider.arel_table[:id].not_in TerminalProfileProvider.arel_table.project(:provider_id)).each do |p|
      terminal_profile_providers << TerminalProfileProvider.new(:provider_id => p.id, :terminal_profile_id => id)
    end
  end

  def self.invalidate_all_cached_providers!
    TerminalProfile.all.each(&:invalidate_cached_providers!)
  end

  def invalidate_cached_providers!
    self.cached_providers_lock.lock do
      self.cached_providers.value = nil
      self.cached_providers_timestamp.value = DateTime.now
    end
  end
  
  def actual_timestamp
    local_timestamp = self.cached_providers_timestamp.value
    
    if local_timestamp.nil? # Redis is not populated yet
      self.cached_providers_timestamp.value = local_timestamp = DateTime.now
    end
    
    local_timestamp
  end
  
  def providers_dump
    providers = Provider.includes(:provider_fields)

    return [] if providers.blank?

    overload  = Hash[self.terminal_profile_providers.map{|x| [x.provider_id, x]}]

    providers.map do |x|
      icon = overload[x.id].icon rescue nil

      if icon.blank?
        icon = x.icon.try(:url)
      else
        icon = icon.url
      end

      {
        :id             => x.id,
        :title          => x.title,
        :keyword        => x.keyword,
        :icon           => icon,
        :priority       => overload[x.id].try(:priority),
        :fields         => x.fields_dump,
        :group_id       => x.provider_group_id,
        :requires_print => x.requires_print
      }
    end
  end

  def promotions_dump
    self.terminal_profile_promotions.map &:provider_id
  end

  def provider_groups_dump
    overload = Hash[self.terminal_profile_provider_groups.map{|x| [x.provider_group_id, x]}]

    ProviderGroup.all.map do |x|
      icon = overload[x.id].icon rescue nil

      if icon.blank?
        icon = x.icon.try(:url)
      else
        icon = icon.url
      end

      {
        :id        => x.id,
        :title     => x.title,
        :icon      => icon,
        :priority  => overload[x.id].try(:priority),
        :parent_id => x.provider_group_id
      }
    end
  end

end
