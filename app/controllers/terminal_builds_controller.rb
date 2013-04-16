class TerminalBuildsController < ApplicationController
  before_filter :authenticate_terminal
  
  def hashes
    render :json => TerminalBuild.find(params[:id]).hashes
  end
end
