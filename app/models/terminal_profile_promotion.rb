class TerminalProfilePromotion < ActiveRecord::Base
  belongs_to :terminal_profile
  belongs_to :provider

  validates :provider, :presence => true
end
