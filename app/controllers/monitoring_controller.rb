class MonitoringController < ApplicationController
  helper 'joosy/sprockets'

  before_filter do
    redirect_to '/admin/' if !current_user
  end

  def index
    render nothing: true, layout: 'application'
  end
end
