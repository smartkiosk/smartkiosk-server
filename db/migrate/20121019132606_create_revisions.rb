class CreateRevisions < ActiveRecord::Migration
  def change
    create_table :revisions do |t|
      t.belongs_to  :gateway
      t.date        :date
      t.string      :state, :null => false, :default => 'new'
      t.integer     :error
      t.decimal     :paid_sum, :precision => 38, :scale => 2
      t.decimal     :enrolled_sum, :precision => 38, :scale => 2
      t.decimal     :commission_sum, :precision => 38, :scale => 2
      t.integer     :payments_count
      t.boolean     :moderated, :null => false, :default => false
      t.string      :data
      t.timestamps
    end

    add_index :revisions, :state
  end
end
