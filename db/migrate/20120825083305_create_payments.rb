class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string          :session_id
      t.integer         :foreign_id
      t.belongs_to      :agent
      t.belongs_to      :terminal
      t.belongs_to      :gateway
      t.belongs_to      :provider
      t.belongs_to      :corrected_payment
      t.belongs_to      :user
      t.belongs_to      :collection
      t.belongs_to      :revision
      t.integer         :payment_type
      t.boolean         :offline, :null => false, :default => false
      t.string          :account
      t.text            :fields
      t.text            :raw_fields
      t.text            :meta
      t.string          :currency, :null => false, :default => 'rur'
      t.decimal         :paid_amount, :precision => 38, :scale => 2
      t.decimal         :commission_amount, :precision => 38, :scale => 2
      t.decimal         :enrolled_amount, :precision => 38, :scale => 2
      t.decimal         :rebate_amount, :precision => 38, :scale => 2
      t.string          :state, :null => false, :default => 'new'
      t.integer         :gateway_error
      t.string          :gateway_provider_id
      t.string          :gateway_payment_id
      t.datetime        :hour
      t.date            :day
      t.date            :month
      t.integer         :source, :null => false, :default => 0
      t.string          :receipt_number
      t.datetime        :paid_at

      t.string          :card_number
      t.string          :card_number_hash
      t.string          :card_track1
      t.string          :card_track2

      t.timestamps
    end

    add_index :payments, :state
    add_index :payments, :agent_id
    add_index :payments, :terminal_id
    add_index :payments, :gateway_id
    add_index :payments, :provider_id
    add_index :payments, :created_at
  end
end
