class CreateProviderGroups < ActiveRecord::Migration
  def change
    create_table :provider_groups do |t|
      t.string      :title
      t.string      :icon
      t.belongs_to  :provider_group
      t.timestamps
    end
  end
end
