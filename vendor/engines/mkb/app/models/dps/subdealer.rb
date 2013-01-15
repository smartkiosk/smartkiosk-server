class DPS::Subdealer < ActiveRecord::Base
  establish_connection "drb"

  self.table_name = 'Subdealers'
  self.primary_key = 'SubdealerId'

  has_one :inner_agent, :class_name => '::Agent', :foreign_key => 'foreign_id'

  def build_inner_agent!
    agent = ::Agent.find_by_id(self.SubdealerId)

    return agent unless agent.blank?

    agent = ::Agent.new(
      :title      => self.Name
    )
    agent.id = self.SubdealerId
    agent.save!

    agent
  end

  def self.import_all!
    all.each{|s| s.build_inner_agent!}
    true
  end
end