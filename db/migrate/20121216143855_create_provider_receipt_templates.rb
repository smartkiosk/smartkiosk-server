class CreateProviderReceiptTemplates < ActiveRecord::Migration
  def change
    create_table :provider_receipt_templates do |t|
      t.boolean     :system, :null => false, :default => false
      t.text        :template
      t.timestamps
    end
  end
end
