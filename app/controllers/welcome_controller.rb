class WelcomeController < ApplicationController
  before_filter do
    redirect_to '/admin/' if !current_user
  end

  def index
    render :text => 'welcome!'
  end

  def terminals
    render :json => Terminal.all
  end
end