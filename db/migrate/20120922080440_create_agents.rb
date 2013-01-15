class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.belongs_to    :agent
      t.string        :title

      t.integer       :foreign_id

      t.string        :juristic_name
      t.string        :juristic_address_city
      t.string        :juristic_address_street
      t.string        :juristic_address_home
      t.string        :physical_address_city
      t.string        :physical_address_district
      t.string        :physical_address_subway
      t.string        :physical_address_street
      t.string        :physical_address_home
      t.string        :contact_name
      t.string        :contact_info
      t.string        :director_name
      t.string        :director_contact_info
      t.string        :bookkeeper_name
      t.string        :bookkeeper_contact_info
      t.string        :inn
      t.string        :support_phone
      t.timestamps
    end
  end
end
