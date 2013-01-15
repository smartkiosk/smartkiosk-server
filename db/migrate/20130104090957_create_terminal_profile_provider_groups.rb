class CreateTerminalProfileProviderGroups < ActiveRecord::Migration
  def change
    create_table :term_prof_provider_groups do |t|
      t.belongs_to    :terminal_profile
      t.belongs_to    :provider_group
      t.string        :icon
      t.integer       :priority, :nil => false, :default => 1000000
      t.timestamps
    end
  end
end
