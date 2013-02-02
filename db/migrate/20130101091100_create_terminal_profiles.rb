class CreateTerminalProfiles < ActiveRecord::Migration
  def change
    create_table :terminal_profiles do |t|

      t.string        :title
      t.string        :support_phone
      t.string        :keyword
      t.string        :logo

      t.timestamps
    end
  end
end
