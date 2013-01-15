class DPS::Terminal < ActiveRecord::Base
  establish_connection "drb"

  self.table_name = 'Terminals'
  self.primary_key = 'TerminalID'

  belongs_to :subdealer, :foreign_key => :SubdealerID
  has_one :inner_terminal, :class_name => '::Terminal', :foreign_key => 'foreign_id'

  def build_inner_terminal!
    terminal = ::Terminal.find_by_id(self.TerminalID)

    return terminal unless terminal.blank?

    terminal = ::Terminal.new(
      :keyword     => self.TerminalID,
      :description => self.Name,
      :agent       => (subdealer.inner_agent || subdealer.build_inner_agent!),
      :address     => self.Address
    )
    terminal.id = self.TerminalID
    terminal.terminal_profile_id = TerminalProfile.find_by_keyword('DPS').id
    terminal.save!

    terminal
  end

  def self.import_all!
    all.each{|t| t.build_inner_terminal!}
    true
  end
end