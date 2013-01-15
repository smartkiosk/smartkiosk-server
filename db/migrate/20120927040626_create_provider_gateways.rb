class CreateProviderGateways < ActiveRecord::Migration
  def change
    create_table :provider_gateways do |t|
      t.belongs_to    :provider
      t.belongs_to    :gateway
      t.integer       :priority
      t.string        :gateway_provider_id
      t.string        :account_mapping
      t.text          :fields_mapping
      t.timestamps
    end
  end
end
