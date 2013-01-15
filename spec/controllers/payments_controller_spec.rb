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
        :session_id => 31337,
        :account    => '9261111111'
      }

    result = ActiveSupport::JSON.decode(response.body)
    result.should == {
      "id"               => 1, 
      "state"            => "checked",
      "requires_print"   => false,
      "limits"           => [{"max"=>"9999.0", "min"=>"0.0", "weight"=>1}],
      "commissions"      => [{"max"=>"9999.0", "min"=>"0.0", "percent_fee"=>nil, "static_fee"=>nil, "weight"=>1}],
      "receipt_template" => "{{ payment_enrolled_amount }}"
    }
  end

  it "pays" do
    post :create,
      :terminal => 'test',
      :provider => 'test',
      :payment  => {
        :session_id => 31337,
        :account    => '9261111111'
      }

    result = ActiveSupport::JSON.decode(response.body)
    result.should == {
      "id"               => 1, 
      "state"            => "checked",
      "requires_print"   => false,
      "limits"           => [{"max"=>"9999.0", "min"=>"0.0", "weight"=>1}],
      "commissions"      => [{"max"=>"9999.0", "min"=>"0.0", "percent_fee"=>nil, "static_fee"=>nil, "weight"=>1}],
      "receipt_template" => "{{ payment_enrolled_amount }}"
    }

    post :pay,
      :terminal => 'test',
      :id => 1,
      :payment => {
        :paid_amount => 100
      }
    response.status.should == 200
  end
end