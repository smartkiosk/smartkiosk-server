class PaymentImporters::DPSWorker
  include Sidekiq::Worker

  def perform(date, page_size=20000)
    payments = DPS::Payment.paid_or_manually.by_date(date).includes(:payment_card, :operator => :inner_provider, :terminal => [:inner_terminal, {:subdealer => :inner_agent}])
    pages    = (payments.count.to_f / page_size.to_f).ceil

    pages.times do |p|
      payments_slice = payments.offset(p*page_size).limit(page_size)

      payment_ids = payments_slice.map{|x| x.PaymentId}
      clones      = []
      exclusions  = []
      gateways    = Gateway.all
      keys        = DPS::GatewayKey.all

      payment_ids.each_slice(1000).to_a.each do |x|
        clones += Payment.where(:source => Payment::SOURCE_IMPORT, :foreign_id => x).select(:foreign_id).map{|x| x.foreign_id}
      end

      record_timestamps = ActiveRecord::Base.record_timestamps

      begin
        while payment = payments_slice.pop do
          next if clones.include?(payment.PaymentId)

          fields = payment.to_payment_fields(gateways, keys)

          if fields[:gateway_id].blank?
            exclusions << payment.GateKeyID
            next
          end

          ActiveRecord::Base.record_timestamps = false
          payment    = Payment.new(fields)
          payment.id = fields[:id]
          payment.save(validate: false)
          ActiveRecord::Base.record_timestamps = record_timestamps
        end
      ensure
        ActiveRecord::Base.record_timestamps = record_timestamps
      end

      exclusions.uniq
    end
  end
end