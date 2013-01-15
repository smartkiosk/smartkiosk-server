class CreateLimits < ActiveRecord::Migration
  def change
    create_table :limits do |t|
      t.belongs_to    :provider_profile
      t.date          :start
      t.date          :finish
      t.timestamps
    end
  end
end
