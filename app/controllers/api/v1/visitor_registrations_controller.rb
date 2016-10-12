class Api::V1::VisitorRegistrationsController < ApplicationController

  def new
    if params[:event_id].present?
      @event = Event.find(params[:event_id])
      @invitee = @event.invitees.build
    end
  end

  def create
    # if params[:event_id].present?
    #   @event = Event.find(params[:event_id])
    #   @invitee = @event.invitees.build(invitee_params)
    #   if @invitee.save
    #     render :status => 200, :json => {:status => "Success", :member_first_name => member_first_name, :member_last_name => member_last_name}
    #     redirect_to
    #   else
    #     render :action => 'new'
    #   end
    # end
  end

  protected
  def invitee_params
    params.require(:invitee).permit!
  end
end
