class CreateTerminalBuilds < ActiveRecord::Migration
  def change
    create_table :terminal_builds do |t|
      t.string      :version
      t.string      :source
      t.text        :hashes
      t.boolean     :gems_ready, :default => false
      t.timestamps
    end
  end
end
