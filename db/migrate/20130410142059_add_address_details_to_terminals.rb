class AddAddressDetailsToTerminals < ActiveRecord::Migration
  def change
    add_column :terminals, :address_details, :text
  end
end
