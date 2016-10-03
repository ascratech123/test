class Admin::ActivityFeedsController < ApplicationController

  def index
    @event = Event.find(params[:event_id])
  end

  def new
    @event = Event.find(params[:event_id])
  end
end
