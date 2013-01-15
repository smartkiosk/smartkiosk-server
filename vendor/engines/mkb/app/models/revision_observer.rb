# encoding: utf-8

class RevisionObserver < ActiveRecord::Observer
  def after_save(revision)
    if revision.state_changed? && revision.state == 'done'
      payments  = revision.payments.includes(:terminal, :agent, :gateway, :provider)
      page_size = 20000
      pages     = (payments.count.to_f / page_size.to_f).ceil
      pages.times do |page|
        payments_slice = payments.offset(page*page_size).limit(page_size).all
        payment_ids    = payments_slice.map{|x| x.id}
        clones         = []

        payment_ids.each_slice(1000).to_a.each do |x|
          clones += CoreBanking::Operation.where(:operid => x).select(:operid).map{|x| x.operid}
        end

        payments_slice.each do |p|
          next if clones.include?(p.id)

          params = p.fields || {}
          params = params.merge(:NUMBER => p.account).map{|k,v| "#{k}=#{v}"}.join("\n")

          CoreBanking::Operation.create!(
            :operid         => p.id,
            :machineid      => p.terminal_id,
            :sub            => p.agent.title,
            :machinename    => p.terminal.keyword,
            :locationname   => p.terminal.address,
            :gatewayid      => DPS::Payment::GATEWAYS.invert[p.gateway.keyword],
            :processor      => p.gateway.title,
            :operatorname   => p.provider.title,
            :amount         => p.paid_amount,
            :comission      => p.commission_amount,
            :transferamount => p.enrolled_amount,
            :currencycode   => Money::Currency.new(p.currency).iso_numeric,
            :sessionid        => p.foreign_id,
            :starttime      => p.created_at,
            :paymentdate    => p.paid_at,
            :resultcode     => p.gateway_error || 0,
            :statusname     => "Платеж завершен",
            :statusid       => 7,
            :params         => params,
            :paymentinfo    => "Реальные платежи"
        )
        end
      end
    end
  end
end