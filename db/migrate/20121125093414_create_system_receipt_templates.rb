class CreateSystemReceiptTemplates < ActiveRecord::Migration
  def change
    create_table :system_receipt_templates do |t|
      t.string      :keyword
      t.text        :template
      t.timestamps
    end
  end
end
