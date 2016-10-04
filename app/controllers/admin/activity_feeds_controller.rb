class Admin::ActivityFeedsController < ApplicationController
  layout 'admin'
  def index
    @event = Event.find(params[:event_id])
  end

  def new
    @event = Event.find(params[:event_id])
  end
end
