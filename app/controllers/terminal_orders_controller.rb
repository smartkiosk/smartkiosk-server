class TerminalOrdersController < ApplicationController
  before_filter :authenticate_terminal

  def acknowledge
    order = @terminal.terminal_orders.find_by_id(params[:id])

    if order.blank?
      render :text => nil, :status => 404
    else
      order.sent!(params[:percent], params[:error])
      render :text => nil, :status => 200
    end
  end

  def complete
    order = @terminal.terminal_orders.find_by_id(params[:id])

    if order.blank?
      render :text => nil, :status => 404
    else
      order.complete!
      render :text => nil, :status => 200
    end
  end
end