require 'spec_helper'

describe CollectionsController do
  render_views

  before(:all) do
    @agent    = Agent.create!(:title => 'test')
    @terminal = Terminal.make!(:keyword => 'test', :agent => @agent)
  end

  it "creates" do
    post :create, :terminal => 'foobar'
    response.status.should == 404

    post :create, :terminal => 'test'
    response.status.should == 400

    post :create, :terminal => 'test', :collection => {
      :session_ids  => ['111', '222'],
      :collected_at => DateTime.now,
      :banknotes    => {
        '10' => 14,
        '1000' => 1
      }
    }

    response.status.should == 200
    collection = @terminal.collections.first
    response.body.should == @terminal.collections.first.id.to_s
    collection.banknotes.should == {'10' => '14', '1000' => '1'}
  end
end
