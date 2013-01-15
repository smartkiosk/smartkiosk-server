class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to '/'
  end

  def authenticate_terminal
    @terminal = Terminal.find_by_keyword(params[:terminal])
    render :text => nil, :status => 404 if @terminal.blank?
  end
end
