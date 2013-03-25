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
      :providers_updated_at => DateTime.now,
    }
    @terminal.pings.count.should >= 1
    @terminal.pings.first.cash_sum.should == 1140
    @terminal.pings.first.ip.should == '127.0.0.1'
  end

  it "updates outdated providers" do
    post :create, :terminal => 'test', :terminal_ping => {
      :providers_updated_at => nil
    }

    body = ActiveSupport::JSON.decode response.body
    body["update_providers"].should == true
  end

  it "properly handles actual providers" do
    post :create, :terminal => 'test', :terminal_ping => {
      :providers_updated_at => DateTime.now,
    }

    body = ActiveSupport::JSON.decode response.body
    body["update_providers"].should == false
  end

  it "delivers correct data" do
    get :providers, :terminal => 'test'

    body = ActiveSupport::JSON.decode response.body
    DateTime.parse(body["updated_at"]).to_i.should == @terminal.terminal_profile.actual_timestamp.to_i
  end

  it "properly handles update scenario" do
    initial_stamp = @terminal.terminal_profile.actual_timestamp

    post :create, :terminal => 'test', :terminal_ping => {
      :providers_updated_at => initial_stamp
      }

    body = ActiveSupport::JSON.decode response.body
    body["update_providers"].should == false

    sleep 1

    @terminal.terminal_profile.invalidate_cached_providers!

    post :create, :terminal => 'test', :terminal_ping => {
      :providers_updated_at => initial_stamp
    }

    body = ActiveSupport::JSON.decode response.body
    body["update_providers"].should == true

    get :providers, :terminal => 'test'

    body = ActiveSupport::JSON.decode response.body
    new_stamp = DateTime.parse(body["updated_at"])
    new_stamp.should > initial_stamp
    new_stamp.to_i.should == @terminal.terminal_profile.actual_timestamp.to_i

    post :create, :terminal => 'test', :terminal_ping => {
      :providers_updated_at => new_stamp
    }

    body = ActiveSupport::JSON.decode response.body
    body["update_providers"].should == false

  end
end
