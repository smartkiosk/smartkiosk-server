class CreateCommissionSections < ActiveRecord::Migration
  def change
    create_table :commission_sections do |t|
      t.belongs_to    :commission
      t.belongs_to    :agent
      t.belongs_to    :terminal_profile
      t.integer       :payment_type

      t.decimal       :min, :precision => 38, :scale => 2
      t.decimal       :max, :precision => 38, :scale => 2

      t.decimal       :percent_fee, :precision => 38, :scale => 2, :null => false, :default => 0
      t.decimal       :static_fee, :precision => 38, :scale => 2, :null => false, :default => 0
      t.timestamps
    end
  end
end
