class Admin::MicrositeTemplatesController < ApplicationController
	layout false
  before_filter :authenticate_user

  def new
  	@microsite = Microsite.find(params[:microsite_id])
  	@event = Event.find(params[:event_id])
  	if @event.microsites.include?(Microsite.find(@microsite.id)).present? and @microsite.template_type == "default_template"
  	end
  end

  def create
    @event = Event.find(params[:event_id])
    @user_microsite = @event.user_microsites.build(user_microsite_params)
    if @user_microsite.save
      redirect_to admin_event_user_microsites_path
    else
      render :action => 'new'
    end
  end
end
