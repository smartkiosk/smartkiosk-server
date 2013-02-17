class SessionRecordsController < ApplicationController
  before_filter :authenticate_terminal

  def create
    session = @terminal.session_records.create! params[:session_record]
    render :text => session.id, :status => 200
  rescue ActiveRecord::RecordInvalid
    render :text => nil, :status => 400
  end
end
