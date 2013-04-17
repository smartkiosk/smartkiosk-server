class WelcomeController < ApplicationController
  before_filter do
    redirect_to '/admin/' if !current_user
  end

  def index
  end
end