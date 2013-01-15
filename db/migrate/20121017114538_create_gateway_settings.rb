class CreateGatewaySettings < ActiveRecord::Migration
  def change
    create_table :gateway_settings do |t|
      t.belongs_to  :gateway
      t.string      :keyword
      t.text        :value
      t.timestamps
    end

    add_index :gateway_settings, [:gateway_id, :keyword]
  end
end
