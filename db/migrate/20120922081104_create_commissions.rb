class CreateCommissions < ActiveRecord::Migration
  def change
    create_table :commissions do |t|
      t.belongs_to    :provider_profile
      t.date          :start
      t.date          :finish
      t.timestamps
    end
  end
end
