class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.belongs_to    :provider_profile
      t.belongs_to    :provider_group
      t.string        :title
      t.string        :keyword
      t.string        :juristic_name
      t.string        :inn
      t.boolean       :requires_print, :null => false, :default => false
      t.integer       :foreign_id
      t.integer       :provider_gateways_count, :default => 0
      t.string        :icon

      t.belongs_to    :provider_receipt_template

      t.timestamps
    end

    add_index :providers, :keyword, :unique => true
    add_index :providers, :updated_at
  end
end
