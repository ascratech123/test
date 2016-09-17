class Admin::UserMicrositesController < ApplicationController
	layout false
  before_filter :authenticate_user
  before_filter :find_event, :only => [:new, :create, :show]

  def new
  	@microsite = Microsite.find(params[:microsite_id])
  end

  def create
    @user_microsite = @event.user_microsites.build(field1: params[:microsite][:field1], field2: params[:microsite][:field2], field3: params[:microsite][:field3], field4: params[:microsite][:field4], field5: params[:microsite][:field5])
    if @user_microsite.save
      redirect_to admin_event_microsites_path
    else
    	redirect_to new_admin_event_microsite_template_path(:microsite_id => params[:microsite_id], :error => 1)
    end
  end

  def show
  	@user_microsite = UserMicrosite.find(params[:id])
  end

  def find_event
    @event = Event.find(params[:event_id])
  end
end
