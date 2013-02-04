class TerminalProfile < ActiveRecord::Base
  include Redis::Objects::RMap

  has_rmap({:id => lambda{|x| x.to_s}}, :title)
  has_paper_trail

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
end
