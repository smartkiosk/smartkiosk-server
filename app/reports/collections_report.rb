# coding: utf-8

class CollectionsReport < ReportBuilder::Base
  requires_dates!

  def tables
    @tables ||= {
      :collection => Arel::Table.new(:collections),
      :terminal   => Arel::Table.new(:terminals),
      :agent      => Arel::Table.new(:agents)
    }.with_indifferent_access
  end

  def context(start, finish)
    context = tables[:collection]

    context = context.join(tables[:terminal], Arel::Nodes::OuterJoin).on(tables[:collection][:terminal_id].eq tables[:terminal][:id])
    context = context.join(tables[:agent], Arel::Nodes::OuterJoin).on(tables[:terminal][:agent_id].eq tables[:agent][:id])

    context = context.where(tables[:collection][:created_at].in(start..finish))

    context
  end

  def groupping
    %w(
      collection.agent_id
      collection.terminal_id
      collection.hour
      collection.day
      collection.month
    )
  end

  def fields
    {
      '' => %w(
          collection.terminal_id
          terminal.keyword
          terminal.address
          terminal.version
          terminal.issues_started_at
          terminal.collected_at
          terminal.printer_error
          terminal.cash_acceptor_error
          terminal.juristic_name
          terminal.sector
          terminal.contact_name
          terminal.contact_phone
          terminal.contact_email
          terminal.schedule
          terminal.juristic_name
          terminal.contract_number
          terminal.manager
          terminal.rent
          terminal.rent_finish_date
          terminal.collection_zone
          terminal.check_phone_number
          collection.agent_id
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
          collection.created_at
          collection.approved_payments_sum
          collection.cash_sum
          collection.payments_sum
        ),
      'collection.terminal_id' => %w(
          collection.terminal_id
          terminal.keyword
          terminal.address
          terminal.version
          terminal.issues_started_at
          terminal.collected_at
          terminal.printer_error
          terminal.cash_acceptor_error
          terminal.juristic_name
          terminal.sector
          terminal.contact_name
          terminal.contact_phone
          terminal.contact_email
          terminal.schedule
          terminal.juristic_name
          terminal.contract_number
          terminal.manager
          terminal.rent
          terminal.rent_finish_date
          terminal.collection_zone
          terminal.check_phone_number
        ),
      'collection.agent_id' => %w(
          collection.agent_id
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
      'collection.hour' => %w(
          collection.hour
        ),
      'collection.day' => %w(
          collection.day
        ),
      'collection.month' => %w(
          collection.month
        )
    }
  end

  def calculations
    {
      :cash_sum              => lambda{|q, t| t.groupping.blank? ? q : q.project('SUM(collections.cash_sum) AS "cash_sum"') },
      :approved_payments_sum => lambda{|q, t| t.groupping.blank? ? q : q.project('SUM(collections.approved_payments_sum) AS "approved_payments_sum"') },
      :payments_sum          => lambda{|q, t| t.groupping.blank? ? q : q.project('SUM(collections.payments_sum) AS "payments_sum"') }
    }.with_indifferent_access
  end

  def conditions
    {
    }
  end
end