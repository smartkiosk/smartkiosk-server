class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.belongs_to    :agent
      t.belongs_to    :terminal
      t.integer       :source, :null => false, :default => 0
      t.boolean       :reset_counters, :null => false, :default => true
      t.integer       :foreign_id
      t.decimal       :payments_sum, :precision => 38, :scale => 2
      t.integer       :payments_count
      t.decimal       :receipts_sum, :precision => 38, :scale => 2
      t.decimal       :approved_payments_sum, :precision => 38, :scale => 2
      t.integer       :approved_payments_count
      t.decimal       :cash_sum, :precision => 38, :scale => 2
      t.integer       :cash_payments_count
      t.integer       :cashless_payments_count
      t.text          :banknotes
      t.text          :session_ids
      t.datetime      :collected_at
      t.datetime      :hour
      t.date          :day
      t.date          :month
      t.timestamps
    end
  end
end
