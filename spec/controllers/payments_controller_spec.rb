require 'spec_helper'

describe PaymentsController do
  render_views

  before(:all) do
    @profile  = ProviderProfile.make!
    @agent    = Agent.create!(:title => 'test')
    @terminal = Terminal.make!(:keyword => 'test', :agent => @agent)
    @provider = Provider.make!(:provider_profile => @profile, :title => 'test', :keyword => 'test')
    @gateway  = Gateway.create!(:title => 'test', :keyword => 'dummy', :payzilla => 'dummy')

    ProviderGateway.create!(:provider => @provider, :gateway => @gateway, :priority => 1)

    ProviderReceiptTemplate.create!(
      :system   => true,
      :template => "{{ payment_enrolled_amount }}"
    )

    @commission = Commission.create! :provider_profile => @profile,
      :start => '1000-1-1', :finish => '9999-1-1'

    @limit = Limit.create! :provider_profile => @profile,
      :start => '1000-1-1', :finish => '9999-1-1'

    CommissionSection.create! :commission => @commission, :min => 0, :max => 9999
    LimitSection.create! :limit => @limit, :min => 0, :max => 9999
  end

  it "creates" do
    post :create,
      :terminal => 'test',
      :provider => 'test',
      :payment  => {
        :session_id   => 31337,
        :account      => '9261111111',
        :payment_type => Payment::TYPE_CASH
      }

    result = ActiveSupport::JSON.decode(response.body)
    result.should == {
      "id"               => 1,
      "state"            => "checked",
      "requires_print"   => true,
      "limits"           => [{"max"=>"9999.0", "min"=>"0.0", "weight"=>1}],
      "commissions"      => [{"max"=>"9999.0", "min"=>"0.0", "payment_type"=>nil, "percent_fee"=>"0.0", "static_fee"=>"0.0", "weight"=>1}],
      "receipt_template" => "{{ payment_enrolled_amount }}"
    }
  end

  it "declines empty provider" do
    post :create,
      :terminal => 'test',
      :payment  => {
        :session_id   => 31337,
        :account      => '9261111111',
        :payment_type => Payment::TYPE_CASH
      }

    response.code.should == "406"
  end

  it "declines absent provider" do
    post :create,
      :terminal => 'test',
      :provider => 'idontexist',
      :payment  => {
        :session_id   => 31337,
        :account      => '9261111111',
        :payment_type => Payment::TYPE_CASH
      }

    response.code.should == "406"
  end

  it "declines duplicating session id" do
    post :create,
      :terminal => 'test',
      :provider => 'test',
      :payment  => {
        :session_id   => 31337,
        :account      => '9261111111',
        :payment_type => Payment::TYPE_CASH
      }

    post :create,
      :terminal => 'test',
      :provider => 'test',
      :payment  => {
        :session_id   => 31337,
        :account      => '9261111111',
        :payment_type => Payment::TYPE_CASH
      }

    response.code.should == "406"
  end

  it "pays" do
    post :create,
      :terminal => 'test',
      :provider => 'test',
      :payment  => {
        :session_id   => 31337,
        :account      => '9261111111',
        :payment_type => Payment::TYPE_CASH
      }

    result = ActiveSupport::JSON.decode(response.body)
    result.should == {
      "id"               => 1,
      "state"            => "checked",
      "requires_print"   => true,
      "limits"           => [{"max"=>"9999.0", "min"=>"0.0", "weight"=>1}],
      "commissions"      => [{"max"=>"9999.0", "min"=>"0.0", "payment_type"=>nil, "percent_fee"=>"0.0", "static_fee"=>"0.0", "weight"=>1}],
      "receipt_template" => "{{ payment_enrolled_amount }}"
    }

    post :pay,
      :terminal => 'test',
      :id => 1,
      :payment => {
        :paid_amount => 100
      }
    response.status.should == 200

    PayWorker.new.perform 1
    payment = Payment.find 1
    payment.state.should == "paid"
  end

  xit "pays with card" do
    post :create,
      :terminal => 'test',
      :provider => 'test',
      :payment => {
        :session_id   => 31337,
        :account      => '9261111111',
        :payment_type => Payment::TYPE_INNER_CARD
      }

    result = ActiveSupport::JSON.decode(response.body)
    result.should == {
      "id"               => 1,
      "state"            => "checked",
      "requires_print"   => true,
      "limits"           => [{"max"=>"9999.0", "min"=>"0.0", "weight"=>1}],
      "commissions"      => [{"max"=>"9999.0", "min"=>"0.0", "payment_type"=>nil, "percent_fee"=>"0.0", "static_fee"=>"0.0", "weight"=>1}],
      "receipt_template" => "{{ payment_enrolled_amount }}"
    }
    post :pay,
      :terminal => 'test',
      :id => 1,
      :payment => {
        :card_track1  => "B4432710006099018^CARD2/TEST                ^1412121170030000000000693000000",
        :card_track2  => "4432710006099018=141212117003693",
        :paid_amount => 100
      }
    response.status.should == 200

    begin
      PayWorker.new.perform 1

      payment = Payment.find 1

      payment.state.should == "paid"
    ensure
      CardsMkbAcquirer.stop
    end
  end
end
