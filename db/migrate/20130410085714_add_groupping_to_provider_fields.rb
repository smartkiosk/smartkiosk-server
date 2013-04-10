class AddGrouppingToProviderFields < ActiveRecord::Migration
  def change
    add_column :provider_fields, :groupping, :string
  end
end
