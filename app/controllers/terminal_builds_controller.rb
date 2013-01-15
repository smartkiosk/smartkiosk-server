class TerminalBuildsController < ApplicationController
  def hashes
    render :json => TerminalBuild.find(params[:id]).hashes
  end
end
