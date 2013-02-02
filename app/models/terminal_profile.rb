class TerminalProfile < ActiveRecord::Base
  include Redis::Objects::RMap

  has_rmap({:id => lambda{|x| x.to_s}}, :keyword)
  has_paper_trail

  has_many :terminals, :conditions => "terminal_profile_id IS NOT NULL"
  has_many :terminal_profile_promotions, :dependent => :destroy, :order => :priority
  has_many :terminal_profile_providers, :dependent => :destroy, :order => :priority
  has_many :terminal_profile_provider_groups, :dependent => :destroy, :order => :priority

  accepts_nested_attributes_for :terminal_profile_promotions, :allow_destroy => true
  accepts_nested_attributes_for :terminal_profile_providers
  accepts_nested_attributes_for :terminal_profile_provider_groups

  def terminal_profile_provider_groups(parent=false)
    data = TerminalProfileProviderGroup.where(:terminal_profile_id => id).
      includes(:provider_group => :provider_group).order(:priority)

    data  = data.where(:provider_groups => {:provider_group_id => parent}) unless parent === false
    pgids = data.map{|x| x.provider_group_id}

    ProviderGroup.all.each do |pg|
      unless pgids.include?(pg.id)
        data << TerminalProfileProviderGroup.new(:provider_group_id => pg.id, :terminal_profile_id => id)
      end
    end

    data
  end

  def terminal_profile_providers(category=nil)
    category = category.id if !category.blank? && category.respond_to?(:id)
    search   = category.nil? ? {} : {:provider_group_id => category}

    data = TerminalProfileProvider.includes(:provider).
      where(:terminal_profile_id => id, :providers => search).
      order("terminal_profile_providers.priority")
    pids = data.map{|x| x.provider_id}

    Provider.where(search).all.each do |p|
      unless pids.include?(p.id)
        data << TerminalProfileProvider.new(:provider_id => p.id, :terminal_profile_id => id)
      end
    end

    data
  end
end
