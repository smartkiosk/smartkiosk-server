class SystemReceiptTemplatesController < ApplicationController
  before_filter :authenticate_terminal

  def index
    templates = SystemReceiptTemplate.unscoped
    templates = templates.new_from(params[:date]) unless params[:date].blank?

    render :json => templates.as_json(:only => [:keyword, :template])
  end
end
