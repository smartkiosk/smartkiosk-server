class DPS::Incassation < ActiveRecord::Base
  establish_connection "drb"

  self.table_name = 'incassations'
  self.primary_key = 'IncassID'

  belongs_to :terminal, :foreign_key => :TerminalID

  scope :by_date, proc {|date|
    date   = date.to_date
    start  = date.to_datetime
    finish = start + 1.day - 1.second

    where("[ServerDateTime] BETWEEN '#{start.strftime("%Y-%m-%dT%H:%M:%S")}' AND '#{finish.strftime("%Y-%m-%dT%H:%M:%S")}'")
  }

  def to_collection_fields
    {
      :id                    => self.IncassID,
      :terminal_id           => (terminal.inner_terminal || terminal.build_inner_terminal!).id,
      :agent_id              => (terminal.subdealer.inner_agent || terminal.subdealer.build_inner_agent!).id,
      :source                => Collection::SOURCE_IMPORT,
      :created_at            => self.ServerDateTime,
      :updated_at            => self.ServerDateTime,
      :collected_at          => self.EventDateTime,
      :cash_sum              => self.Amount,
      :payments_sum          => self.MonitoringAmount || 0,
      :approved_payments_sum => self.FullMonitoringAmount || 0,
      :receipts_sum          => self.PrintAmount || 0,
      :banknotes             => parse_notes(self.NoteData),
      :reset_counters        => self.Flags.to_i == 0
    }
  end

  def parse_notes(notes)
    return {} if notes.blank?

    notes = notes.split(';').map{|x| x.split('(')[1].gsub(')', '').split(':')}
    Hash[*notes.flatten]
  end
end