class CreateTerminals < ActiveRecord::Migration
  def change
    create_table :terminals do |t|
      t.belongs_to  :agent
      t.belongs_to  :terminal_profile
      t.string      :address
      t.string      :keyword
      t.string      :description
      t.string      :state, :default => 'unknown'
      t.string      :condition
      t.datetime    :notified_at
      t.datetime    :collected_at
      t.datetime    :issues_started_at

      t.integer     :foreign_id

      t.string      :sector
      t.string      :contact_name
      t.string      :contact_phone
      t.string      :contact_email
      t.string      :schedule
      t.string      :juristic_name
      t.string      :contract_number
      t.string      :manager
      t.string      :rent
      t.string      :rent_finish_date
      t.string      :collection_zone
      t.string      :check_phone_number

      t.integer     :printer_error
      t.integer     :cash_acceptor_error
      t.integer     :modem_error
      t.string      :version

      t.boolean     :has_adv_monitor, :null => false, :default => true

      t.integer     :incomplete_orders_count, :null => false, :default => 0

      t.timestamps
    end

    add_index :terminals, :keyword
    add_index :terminals, :state
    add_index :terminals, :condition
    add_index :terminals, :agent_id
  end
end
