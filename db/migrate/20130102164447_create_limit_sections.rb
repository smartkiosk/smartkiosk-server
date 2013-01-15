class CreateLimitSections < ActiveRecord::Migration
  def change
    create_table :limit_sections do |t|
      t.belongs_to    :limit
      t.belongs_to    :agent
      t.belongs_to    :terminal
      t.integer       :payment_type
      
      t.decimal       :min, :precision => 38, :scale => 2
      t.decimal       :max, :precision => 38, :scale => 2
      t.timestamps
    end
  end
end
