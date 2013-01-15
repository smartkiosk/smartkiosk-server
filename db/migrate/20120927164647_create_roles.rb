class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string      :keyword
      t.timestamps
    end

    create_table :user_roles do |t|
      t.belongs_to :user
      t.belongs_to :role
      t.text       :priveleges
    end
  end
end
