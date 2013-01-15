require 'spec_helper'

describe TerminalOrdersController do
  before(:all) do
    @agent    = Agent.create!(:title => 'test')
    @terminal = Terminal.make!(:keyword => 'test', :agent => @agent)

    @terminal.order! :enable

    @order = @terminal.terminal_orders.first
    @spy   = Terminal.make!(:keyword => 'test2', :agent => @agent)
  end

  it "acknowledges" do
    post :acknowledge, :terminal => @spy.keyword, :id => @order.id
    response.status.should == 404

    post :acknowledge, :terminal => @terminal.keyword, :id => @order.id, :error => 'test'
    response.status.should == 200
    @order.reload.sent?.should == true
    @order.error?.should == true
  end

  it "completes" do
    post :complete, :terminal => @spy.keyword, :id => @order.id
    response.status.should == 404

    post :complete, :terminal => @terminal.keyword, :id => @order.id
    response.status.should == 200
    @order.reload.complete?.should == true
  end
end
