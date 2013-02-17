class SessionRecord < ActiveRecord::Base
  #
  # RELATIONS
  #
  belongs_to :terminal

  #
  # VALIDATIONS
  #
  validates :terminal, :presence => true
  validates :message_id, :presence => true, :uniqueness => true
  validates :started_at, :presence => true
  validates :upstream, :presence => true
  validates :downstream, :presence => true
  validates :time, :presence => true

  after_create do
    if terminal.last_session_started_at.blank? ||
       self.started_at > terminal.last_session_started_at

      terminal.update_attribute(:last_session_started_at, self.started_at)
    end
  end
end
