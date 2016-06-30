class Admin::UserRegistrationsController < ApplicationController
	# layout 'admin'

  before_filter :find_event
  skip_before_filter :authenticate_user, :load_filter
    
  def index
   # redirect_to new_admin_event_user_registration_path(:event_id => @event.id) 
   @registration = @event.registrations.first
    if @registration.blank?
      redirect_to :back
    else
      @user_registrations = @event.user_registrations.paginate(page: params[:page], per_page: 10)
      render :layout => 'admin'
    end
  end

  def new
    # if Rails.application.routes.recognize_path(request.referrer)[:controller] == "admin/registrations" 
    #   @custom_registration  = @registration.custom_source_code
    if @event.registrations.present?
      @registration = @event.registrations.first 
      @user_registration = @event.user_registrations.build
      @registration_setting = @event.registration_settings.first
      if @registration_setting.registration == "hobnob" and @registration_setting.template == "custom"
        render :layout => false #"admin/layouts/user_registration"
      end
    else
      redirect_to admin_dashboards_path
    end
  end

  def create
    @registration = @event.registrations.first
    @user_registration = @event.user_registrations.build(user_registration_params)
    if @user_registration.save
      redirect_to @event.registration_settings.first.reg_surl
    else
      # if Rails.application.routes.recognize_path(request.referrer)[:controller] == "admin/registrations" and @event.registration_settings.present?
      #   @registration_setting =  @event.registration_settings.first
      # end
      if @event.registration_settings.first.template == "custom" and params[:action] == "create"
        @registration_setting = @event.registration_settings.first
        render :action => 'new',:layout => "admin/layouts/user_registration.html.haml"
      else
        render :action => 'new'
      end
    end
  end

  def show
  end


  protected
  
  def find_event
    @event = Event.find(params[:event_id])
  end

  def user_registration_params
    params.require(:user_registration).permit! if params[:user_registration].present?
  end
end