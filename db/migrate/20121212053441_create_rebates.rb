class CreateRebates < ActiveRecord::Migration
  def change
    create_table :rebates do |t|
      t.belongs_to    :gateway

      t.decimal       :period_fee
      t.integer       :period_kind

      t.date          :start
      t.date          :finish

      t.timestamps
    end
  end
end
