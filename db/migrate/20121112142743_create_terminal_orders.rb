class CreateTerminalOrders < ActiveRecord::Migration
  def change
    create_table :terminal_orders do |t|
      t.belongs_to    :terminal
      t.string        :keyword
      t.text          :args
      t.string        :state, :null => false, :default => 'new'
      t.string        :error
      t.integer       :percent
      t.timestamps
    end
  end
end
