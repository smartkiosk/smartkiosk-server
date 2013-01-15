class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.belongs_to    :report_template
      t.belongs_to    :user
      t.date          :start
      t.date          :finish
      t.string        :state, :null => false, :default => 'new'
      t.text          :error
      t.timestamps
    end
  end
end