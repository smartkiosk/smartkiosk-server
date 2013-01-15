class CreateReportResults < ActiveRecord::Migration
  def change
    create_table :report_results do |t|
      t.integer         :rows
      t.belongs_to      :report
      t.text            :data
      t.timestamps
    end
  end
end
