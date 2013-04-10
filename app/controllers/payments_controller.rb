# coding: utf-8
class PaymentsController < ApplicationController
  before_filter :authenticate_terminal

  def limits
    provider = Provider.find_by_keyword params[:provider]

    render :json => provider.limits.actual.
                      by_terminal_profile_and_agent_ids(@terminal.terminal_profile_id, @terminal.agent_id).
                      by_payment_type(params[:payment_type]).
                      as_json(:only => [:min, :max], :methods => [:weight])
  end

  def create
    payment = Payment.build!(@terminal, Provider.find_by_keyword(params[:provider]), params[:payment])

    if payment
      payment.check!

      render :json => {
        :id               => payment.id,
        :state            => payment.state,
        :requires_print   => payment.provider.requires_print,
        :limits           => Limit.for(payment, false).as_json(
                                :only => [:min, :max], :methods => [:weight]
                             ),
        :commissions      => Commission.for(payment, false).as_json(
                                :only => [:min, :max, :percent_fee, :static_fee, :payment_type],
                                :methods => [:weight]
                             ),
        :receipt_template => ProviderReceiptTemplate.for(payment).compile(payment)
      }
    else
      render :text => nil, :status => 406
    end
  end

  def offline
    payment = Payment.build!(@terminal, Provider.find_by_keyword(params[:provider]), params[:payment])
    payment.check!
    payment.enqueue! if payment.checked?

    render :json => payment.as_json
  end
  
  def pay
    payment = @terminal.payments.find(params[:id])
    payment.pay!(params[:payment])

    render :json => payment.as_json
  end

  def enqueue
    payment = @terminal.payments.find(params[:id])
    payment.enqueue!(params[:payment]) unless payment.queue?

    render :text => nil, :status => 200
  end

  def show
    payment = @terminal.payments.find(params[:id])

    render :json => payment.as_json
  end
end
