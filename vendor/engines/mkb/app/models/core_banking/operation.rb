class CoreBanking::Operation < ActiveRecord::Base
  establish_connection "core_banking"

  self.table_name = 'OPERATION'

  attr_accessible :operid, :machineid, :sub, :machinename, :locationname, :gatewayid, 
    :processor, :operatorname, :amount, :comission, :transferamount, :currencycode, 
    :sessionid, :starttime, :paymentdate, :resultcode, :statusname, :statusid, :params,
    :paymentinfo, :cardnumber, :cardnumbermd5

end