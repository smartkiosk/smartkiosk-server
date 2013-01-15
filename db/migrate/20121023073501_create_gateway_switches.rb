class CreateGatewaySwitches < ActiveRecord::Migration
  def change
    create_table :gateway_switches do |t|
      t.belongs_to  :gateway
      t.string      :keyword
      t.boolean     :value, :null => false, :default => false
      t.timestamps
    end
  end
end
