class AddPingToTerminals < ActiveRecord::Migration
  def change
    add_column :terminals, :banknotes, :string
    add_column :terminals, :cash, :decimal, :precision => 38, :scale => 2
    add_column :terminals, :cashless, :decimal, :precision => 38, :scale => 2
    add_column :terminals, :ip, :string
    add_column :terminals, :cash_acceptor_version, :string
    add_column :terminals, :cash_acceptor_model, :string
    add_column :terminals, :modem_version, :string
    add_column :terminals, :modem_model, :string
    add_column :terminals, :modem_signal_level, :string
    add_column :terminals, :modem_balance, :string
    add_column :terminals, :printer_version, :string
    add_column :terminals, :printer_model, :string
    add_column :terminals, :card_reader_version, :string
    add_column :terminals, :card_reader_model, :string
    add_column :terminals, :watchdog_version, :string
    add_column :terminals, :watchdog_model, :string
    add_column :terminals, :upstream, :integer
    add_column :terminals, :downstream, :integer
  end
end
