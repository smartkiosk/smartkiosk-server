class AddWatchdogAndCardReaderErrorsToTerminals < ActiveRecord::Migration
  def change
  	add_column :terminals, :card_reader_error, :integer
  	add_column :terminals, :watchdog_error, :integer
  end
end
