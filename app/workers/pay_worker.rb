class PayWorker
  include Sidekiq::Worker

  def perform(payment_id)
    payment = Payment.find(payment_id)

    payment.plog :info, :queue, "Paid" do
      payment.pay!
    end
  end
end