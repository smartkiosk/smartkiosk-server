class CreateTerminalBuilds < ActiveRecord::Migration
  def change
    create_table :terminal_builds do |t|
      t.string      :version
      t.string      :source
      t.text        :hashes
      t.timestamps
    end
  end
end
