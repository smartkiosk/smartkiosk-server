class CreateGateways < ActiveRecord::Migration
  def change
    create_table :gateways do |t|
      t.string      :title
      t.string      :keyword
      t.string      :payzilla
      t.boolean     :requires_revisions_moderation, :null => false, :default => false
      t.integer     :debug_level, :null => false, :default => 0
      t.boolean     :enabled, :null => false, :default => true
      t.timestamps
    end
  end
end
