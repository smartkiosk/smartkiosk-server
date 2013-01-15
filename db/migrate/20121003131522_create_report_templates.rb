class CreateReportTemplates < ActiveRecord::Migration
  def change
    create_table :report_templates do |t|
      t.string      :kind
      t.string      :title
      t.boolean     :open, :null => false, :default => false
      t.text        :groupping, :null => false, :default => ''
      t.text        :fields
      t.text        :calculations
      t.string      :sorting
      t.boolean     :sort_desc, :null => false, :default => false
      t.text        :conditions
      t.string      :email
      t.belongs_to  :user
      t.timestamps
    end
  end
end
