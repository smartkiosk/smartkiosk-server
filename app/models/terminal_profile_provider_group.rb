class TerminalProfileProviderGroup < ActiveRecord::Base

  self.table_name = 'term_prof_provider_groups'

  mount_uploader :icon, IconUploader

  belongs_to :provider_group
  belongs_to :terminal_profile, :inverse_of => :terminal_profile_provider_groups

  validates :provider_group_id, :uniqueness => {:scope => :terminal_profile_id}
  validates :provider_group, :presence => true
  validates :terminal_profile, :presence => true

  delegate :title, :to => :terminal_profile
end
