# coding: utf-8

class AgentsReport < ReportBuilder::Base
  def tables
    @tables ||= {
      :agent => Arel::Table.new(:agents),
      :parent_agent => Arel::Table.new(:agents).alias("parent_agents")
    }.with_indifferent_access
  end

  def context(start, finish)
    context = tables[:agent]
    context = context.join(tables[:parent_agent], Arel::Nodes::OuterJoin).on(tables[:agent][:agent_id].eq tables[:parent_agent][:id])
    context = context.where(tables[:agent][:created_at].in(start..finish)) if !start.blank? || !finish.blank?
    context
  end

  def groupping
    %w(
      agent.agent_id
    )
  end

  def fields
    {
      '' => %w(
          agent.title
          agent.juristic_name
          agent.juristic_address_city
          agent.juristic_address_street
          agent.juristic_address_home
          agent.physical_address_city
          agent.physical_address_district
          agent.physical_address_subway
          agent.physical_address_street
          agent.physical_address_home
          agent.contact_name
          agent.contact_info
          agent.director_name
          agent.director_contact_info
          agent.bookkeeper_name
          agent.bookkeeper_contact_info
          agent.inn
          agent.support_phone
        ),
      'agent.agent_id' => %w(
          agent.agent_id
          parent_agent.title
          parent_agent.juristic_name
          parent_agent.juristic_address_city
          parent_agent.juristic_address_street
          parent_agent.juristic_address_home
          parent_agent.physical_address_city
          parent_agent.physical_address_district
          parent_agent.physical_address_subway
          parent_agent.physical_address_street
          parent_agent.physical_address_home
          parent_agent.contact_name
          parent_agent.contact_info
          parent_agent.director_name
          parent_agent.director_contact_info
          parent_agent.bookkeeper_name
          parent_agent.bookkeeper_contact_info
          parent_agent.inn
          parent_agent.support_phone
        )
    }
  end

  def calculations
    {
      :quantity => lambda{|q, t| t.groupping.blank? ? q : q.project('COUNT(*) AS "quantity"').where(tables[:agent][:agent_id].not_eq nil) }
    }.with_indifferent_access
  end

  def conditions
    {
      'agent.agent_id' => proc{ Agent.rmap.invert }
    }
  end
end