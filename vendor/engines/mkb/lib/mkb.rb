require 'composite_primary_keys'

require 'dps/params_parser'
require 'dps/params_exporter'

require 'jdbc_fix'
require 'active_record/connection_adapters/jdbc_adapter'

module Mkb
  class Engine < Rails::Engine
    config.active_record.observers = [:payment_observer, :collection_observer]

    config.to_prepare do
      require 'payment_importers/dps_worker'
      require 'collection_importers/dps_worker'
      
      ActiveRecord::ConnectionAdapters::JdbcAdapter.send(:include, JdbcFix)

      Seeder.engines << Mkb

      class ::Payment
        def dps_payment
          return nil unless source == SOURCE_IMPORT
          DPS::Payment.find(foreign_id)
        end

        def cb_operation
          CoreBanking::Operation.find(id)
        end

        def inspect_params
          [dps_payment.Params, cb_operation.Params].inspect
        end

        def mkb?
          !meta[:mkb].blank?
        end
      end
    end
  end
end
