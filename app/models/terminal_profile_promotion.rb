class TerminalProfilePromotion < ActiveRecord::Base
  include Redis::Objects::RMap

  belongs_to :terminal_profile
  belongs_to :provider

  validates :provider, :presence => true

  after_save do
    self.terminal_profile.invalidate_cached_providers!
  end

  after_destroy do
    self.terminal_profile.invalidate_cached_providers!
  end
end
