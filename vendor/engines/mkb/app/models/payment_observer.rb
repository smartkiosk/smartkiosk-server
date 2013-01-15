# encoding: utf-8

class PaymentObserver < ActiveRecord::Observer

  def after_create(payment)
    return if payment.manual?
    CoreBanking::Operation.create! attributes(payment)
  end

  def after_update(payment)
    return if payment.manual?
    entry   = CoreBanking::Operation.where(:operid => payment.id).first
    entry ||= CoreBanking::Operation.new

    entry.assign_attributes attributes(payment)
    entry.save!
  end

  def attributes(p)
    {
      :operid         => p.id,
      :machineid      => p.terminal_id,
      :sub            => p.agent.title,
      :machinename    => p.terminal.description || p.terminal.keyword,
      :locationname   => p.terminal.address || 'No address',
      :gatewayid      => DPS::Payment::GATEWAYS.invert[p.gateway.keyword],
      :processor      => (DPS::Payment::GATEWAY_NAMES[p.gateway.keyword] || p.gateway.title),
      :operatorname   => p.provider.title,
      :amount         => p.paid_amount || 0,
      :comission      => p.commission_amount  || 0,
      :transferamount => p.enrolled_amount  || 0,
      :currencycode   => Money::Currency.new(p.currency).iso_numeric,
      :sessionid      => p.session_id,
      :starttime      => p.created_at,
      :paymentdate    => p.paid_at,
      :resultcode     => p.gateway_error || 0,
      :statusname     => "Платеж завершен",
      :statusid       => p.paid? ? 7 : 100, # 7 - success, 100 - error
      :params         => DPS::ParamsExporter.export(p),
      :paymentinfo    => "Реальные платежи",
      :cardnumber     => p.card_number,
      :cardnumbermd5  => p.card_number_hash
    }
  end

end