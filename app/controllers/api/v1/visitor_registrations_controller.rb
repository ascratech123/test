class Api::V1::VisitorRegistrationsController < ApplicationController
  before_filter :get_event, :only => [:create]
  
  def index
    
  end
  def new
    if params[:event_id].present?
      @event = Event.find(params[:event_id])
      @invitee = @event.invitees.build
    end
  end

  def create
    if @event.present? and (@event.event_type_for_registration.present? and @event.event_type_for_registration == "open")
      @invitee = @event.invitees.build(invitee_params)
      if @invitee.save
        render :status => 200, :json => {:status => "Success", :key => @invitee.key, :authentication_token => @invitee.authentication_token}
      else
        @event_id = @event.id
        render :action => 'new'
      end
    else
      redirect_to api_v1_visitor_registrations_path
    end
  end

  protected
  def get_event
    if params[:invitee][:event_id].present?
      @event = Event.find(params[:invitee][:event_id])
    end  
  end

  def invitee_params
    params.require(:invitee).permit!
  end
end
