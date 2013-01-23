class TerminalProfilePromotion < ActiveRecord::Base
  include Redis::Objects::RMap

  value :timestamp, :global => true, :marshal => true

  belongs_to :terminal_profile
  belongs_to :provider

  validates :provider, :presence => true

  after_save do
    self.class.timestamp = updated_at
  end

  after_destroy do
    self.class.timestamp = DateTime.now
  end
end
