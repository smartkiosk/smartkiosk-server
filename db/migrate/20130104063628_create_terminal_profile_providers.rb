class CreateTerminalProfileProviders < ActiveRecord::Migration
  def change
    create_table :terminal_profile_providers do |t|
      t.belongs_to      :terminal_profile
      t.belongs_to      :provider
      t.string          :icon
      t.integer         :priority, :nil => false, :default => 1000000
      t.timestamps
    end
  end
end
