class CreateProviderFields < ActiveRecord::Migration
  def change
    create_table :provider_fields do |t|
      t.belongs_to    :provider

      t.string        :keyword
      t.string        :title
      t.string        :kind
      t.string        :mask
      t.text          :values
      t.integer       :priority

      t.timestamps
    end
  end
end
