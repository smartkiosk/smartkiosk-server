class CoreBanking::Incassation < ActiveRecord::Base
  establish_connection "core_banking"

  self.table_name = 'INCASSATIONS'

  attr_accessible :incassid, :terminalid, :eventdatetime, :serverdatetime, :amount, 
    :monitoringamount, :fullmonitoringamount, :notedata, :flags, :printamount, :barcode, 
    :fiscalamount, :fiscalmemoryamount, :currencycode
end