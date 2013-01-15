# coding: utf-8

class PaymentsReport < ReportBuilder::Base
  requires_dates!

  def tables
    @tables ||= {
      :terminal => Arel::Table.new(:terminals),
      :payment  => Arel::Table.new(:payments),
      :agent    => Arel::Table.new(:agents),
      :gateway  => Arel::Table.new(:gateways),
      :provider => Arel::Table.new(:providers)
    }.with_indifferent_access
  end

  def context(start, finish)
    context = tables[:payment]

    [:terminal, :agent, :gateway, :provider].each do |x|
      context = context.join(tables[x]).on(tables[:payment][x.to_s + '_id'].eq tables[x][:id])
    end

    context.where(tables[:payment][:created_at].in(start..finish))

    context
  end

  def groupping
    %w(
      payment.state
      payment.terminal_id
      payment.provider_id
      payment.agent_id
      payment.gateway_id
      payment.hour
      payment.day
      payment.month
    )
  end

  def fields
    {
      '' => %w(
          payment.terminal_id
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
          payment.agent_id
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
          payment.gateway_id
          gateway.title
          payment.provider_id
          provider.title
          provider.keyword
          provider.juristic_name
          provider.inn
          payment.session_id
          payment.foreign_id
          payment.corrected_payment_id
          payment.user_id
          payment.collection_id
          payment.revision_id
          payment.payment_type
          payment.account
          payment.fields
          payment.raw_fields
          payment.meta
          payment.currency
          payment.paid_amount
          payment.commission_amount
          payment.enrolled_amount
          payment.rebate_amount
          payment.state
          payment.gateway_error
          payment.gateway_provider_id
          payment.gateway_payment_id
          payment.source
          payment.receipt_number
          payment.paid_at
          payment.card_number
          payment.card_number_hash
        ),
      'payment.state' => %w(
          payment.state
        ),
      'payment.terminal_id' => %w(
          payment.terminal_id
          terminal.keyword
          terminal.address
          terminal.juristic_name
          terminal.manager
          terminal.rent
          terminal.address
        ),
      'payment.provider_id' => %w(
          payment.provider_id
          provider.title
          provider.keyword
          provider.juristic_name
          provider.inn
        ),
      'payment.agent_id' => %w(
          payment.agent_id
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
      'payment.gateway_id' => %w(
          payment.gateway_id
          gateway.title
        ),
      'payment.hour' => %w(
          payment.hour
        ),
      'payment.month' => %w(
          payment.month
        ),
      'payment.day' => %w(
          payment.day
        )
    }
  end

  def calculations
    {
      :quantity   => lambda{|q, t| t.groupping.blank? ? q : q.project('COUNT(*) AS "calculations.quantity"') },
      :enrolled   => lambda{|q, t| t.groupping.blank? ? q : q.project('SUM(enrolled_amount) AS "calculations.enrolled"') },
      :paid       => lambda{|q, t| t.groupping.blank? ? q : q.project('SUM(paid_amount) AS "calculations.paid"') },
      :commission => lambda{|q, t| t.groupping.blank? ? q : q.project('SUM(commission_amount) AS "calculations.commission"') }
    }.with_indifferent_access
  end

  def conditions
    {
      'payment.state' => proc { I18n.t('smartkiosk.payment_states') },
      'payment.payment_type' => proc { I18n.t('smartkiosk.payment_types') }
    }
  end
end