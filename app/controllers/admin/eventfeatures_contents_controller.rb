class Admin::EventfeaturesContentsController < ApplicationController
  layout 'admin'

  before_filter :authenticate_user
  
  def index
    respond_to do |format|
      @event = Event.find_by_id(params[:parent_event_id])
      @event_features = @event.event_features.where(:status => "active").pluck(:name)
      # @selected_event = Event.where(:id => params[:event_id], event_name: params[:event_name], client_id: params[:client_id])
      format.js { @event_features }
    end
	end

end