class AddLastSessionStartedAtToTerminals < ActiveRecord::Migration
  def change
    add_column :terminals, :last_session_started_at, :integer, :null => false, :default => 0
  end
end
