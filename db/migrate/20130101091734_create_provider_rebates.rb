class CreateProviderRebates < ActiveRecord::Migration
  def change
    create_table :provider_rebates do |t|

      t.belongs_to    :rebate

      t.belongs_to    :provider
      t.boolean       :requires_commission
      t.integer       :payment_type

      t.decimal       :min, :precision => 38, :scale => 2
      t.decimal       :max, :precision => 38, :scale => 2

      t.decimal       :min_percent_amount, :precision => 38, :scale => 2, :null => false, :default => 0.0
      t.decimal       :percent_fee, :precision => 38, :scale => 2
      t.decimal       :static_fee, :precision => 38, :scale => 2

      t.timestamps
    end
  end
end
