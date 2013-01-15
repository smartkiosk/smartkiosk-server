class CreateTerminalProfilePromotions < ActiveRecord::Migration
  def change
    create_table :terminal_profile_promotions do |t|
      t.belongs_to    :terminal_profile
      t.belongs_to    :provider
      t.integer       :priority
      t.timestamps
    end
  end
end
