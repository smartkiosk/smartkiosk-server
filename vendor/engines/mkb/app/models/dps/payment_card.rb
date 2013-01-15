class DPS::PaymentCard < ActiveRecord::Base
  establish_connection "drb"

  self.table_name = 'F13_CardPayments'
  set_primary_keys 'TerminalID', 'InitialSessionNumber'
end