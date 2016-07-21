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
      respond_to do |format|
        format.html do
          @user_registrations = @user_registrations.paginate(page: params[:page], per_page: 10)
          render :layout => 'admin'
        end  
        format.xls do
          @export_array = [@registration.selected_column_values]
          method_allowed = []
          @only_columns = @registration.selected_columns
          for invitee in @user_registrations
            arr = @only_columns.map{|c| invitee.attributes[c]}
            @export_array << arr
          end
          send_data @export_array.to_reports_xls, filename: "registered_user_#{@registration.id}.xls"
        end
      end
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

  def update
    @user_registrations = @event.user_registrations.paginate(page: params[:page], per_page: 10)
    @user_registration = @user_registrations.find_by_id(params[:id])
    @user_registration.update_attributes(:status => params[:status]) if params[:status].present? and params[:manual_approve].present? and params[:manual_approve] == 'true'
    redirect_to :back
  end


  protected
  
  def find_event
    @event = Event.find(params[:event_id])
  end

  def user_registration_params
    params.require(:user_registration).permit! if params[:user_registration].present?
  end
end