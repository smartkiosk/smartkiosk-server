# coding: utf-8

class TerminalsReport < ReportBuilder::Base
  def tables
    @tables ||= {
      :terminal         => Arel::Table.new(:terminals),
      :agent            => Arel::Table.new(:agents),
      :terminal_profile => Arel::Table.new(:terminal_profiles)
    }.with_indifferent_access
  end

  def context(start, finish)
    context = tables[:terminal]

    [:agent, :terminal_profile].each do |x|
      context = context.join(tables[x], Arel::Nodes::OuterJoin).on(tables[:terminal][x.to_s + '_id'].eq tables[x][:id])
    end

    context
  end

  def groupping
    %w(
      terminal.agent_id
      terminal.terminal_profile_id
      terminal.printer_error
      terminal.cash_acceptor_error
      terminal.version
    )
  end

  def fields
    {
      '' => %w(
          terminal.agent_id
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
      'terminal.agent_id' => %w(
          terminal.agent_id
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
      'terminal.terminal_profile_id' => %w(
          terminal.terminal_profile_id
          terminal_profile.title
        ),
      'terminal.printer_error' => %w(
          terminal.printer_error
        ),
      'terminal.cash_acceptor_error' => %w(
          terminal.cash_acceptor_error
        ),
      'terminal.version' => %w(
          terminal.version
        )
    }
  end

  def calculations
    {
      :quantity => lambda{|q, t| t.groupping.blank? ? q : q.project('COUNT(*) AS "calculations.quantity"') }
    }.with_indifferent_access
  end

  def conditions
    {
      'terminal.condition' => proc { I18n.t('smartkiosk.terminal_conditions') }
    }
  end
end