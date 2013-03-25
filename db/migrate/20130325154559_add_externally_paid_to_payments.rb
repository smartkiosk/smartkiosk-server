class AddExternallyPaidToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :externally_paid, :boolean, :null => false, :default => false
  end
end
