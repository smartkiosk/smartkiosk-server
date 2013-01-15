require 'spec_helper'

describe TerminalPingsController do
  before(:all) do
    @agent    = Agent.create!(:title => 'test')
    @terminal = Terminal.make!(:keyword => 'test', :agent => @agent)
  end

  it "creates" do
    post :create, :terminal => 'foobar'
    response.status.should == 404

    post :create, :terminal => 'test', :terminal_ping => {
      :banknotes => {
        '10' => '14',
        '1000' => '1'
      },
      :ip => '127.0.0.1',
      :cash_acceptor => {
        'error' => '-1'
      },
      :providers => {
        :updated_at => DateTime.now,
        :ids => [1, 2, 3]
      }
    }
    @terminal.pings.count.should == 1
    @terminal.pings.first.cash_sum.should == 1140
    @terminal.pings.first.ip.should == '127.0.0.1'
  end
end
