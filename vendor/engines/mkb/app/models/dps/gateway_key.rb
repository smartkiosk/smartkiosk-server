class DPS::GatewayKey < ActiveRecord::Base
  establish_connection "drb"

  self.table_name = 'mcb_link_gateways_links'
  self.primary_key = 'GatewayID'
end