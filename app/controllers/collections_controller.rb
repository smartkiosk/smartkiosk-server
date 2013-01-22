class CollectionsController < ApplicationController
  before_filter :authenticate_terminal

  def create
    collection = @terminal.collections.create! params[:collection]
    render :text => collection.id, :status => 200
  rescue ActiveRecord::RecordInvalid
    render :text => nil, :status => 400
  end
end
