class TerminalProfileProvider < ActiveRecord::Base

  mount_uploader :icon, IconUploader

  belongs_to :provider
  belongs_to :terminal_profile, :inverse_of => :terminal_profile_providers

  validates :provider_id, :uniqueness => {:scope => :terminal_profile_id}
  validates :provider, :presence => true
  validates :terminal_profile, :presence => true
end
