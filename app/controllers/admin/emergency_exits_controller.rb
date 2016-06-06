class Admin::EmergencyExitsController < ApplicationController

layout 'admin'

before_filter :authenticate_user, :authorize_event_role, :find_features

  def index
  end

  def new
    if @event.emergency_exit.nil?
      @emergency_exit = @event.build_emergency_exit
    else
      redirect_to edit_admin_event_emergency_exit_path(:event_id => @event.id, :id => @event.emergency_exit.id)
    end  
  end

  def create
    @emergency_exit = @event.build_emergency_exit(emergency_exit_params)
    if @emergency_exit.save
      redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application.id)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @emergency_exit.update_attributes(emergency_exit_params)
      redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application.id,:type => "show_content")
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @emergency_exit.destroy
      redirect_to admin_event_emergency_exits_path(:event_id => @emergency_exit.event_id)
    end
  end

  protected

  def emergency_exit_params
    params.require(:emergency_exit).permit!
  end

end
