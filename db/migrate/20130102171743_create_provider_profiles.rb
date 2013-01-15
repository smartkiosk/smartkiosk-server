class CreateProviderProfiles < ActiveRecord::Migration
  def change
    create_table :provider_profiles do |t|

      t.string      :title

      t.timestamps
    end
  end
end
