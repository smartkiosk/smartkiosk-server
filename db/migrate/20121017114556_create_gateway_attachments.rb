class CreateGatewayAttachments < ActiveRecord::Migration
  def change
    create_table :gateway_attachments do |t|
      t.belongs_to  :gateway
      t.string      :keyword
      t.string      :value
      t.timestamps
    end
  end
end
