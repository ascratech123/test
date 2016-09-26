class Admin::CustomPage4sController < ApplicationController
  layout 'admin'
  # load_and_authorize_resource :except => [:create]
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :check_user_role

  def index
    #@custom_pages = @custom_page4s.paginate(page: params[:page], per_page: 10)
    if @event.present? and @event.custom_page4s.present?
      redirect_to edit_admin_event_custom_page4_path(:event_id => params[:event_id],:id => @event.custom_page4s.last.id)
    else
      redirect_to new_admin_event_custom_page4_path(:event_id => params[:event_id])
    end
  end

  def new
    if @event.present? and @event.custom_page4s.present?
      redirect_to edit_admin_event_custom_page4_path(:event_id => params[:event_id],:id => @event.custom_page4s.last.id)
    else
      @custom_page4 = @event.custom_page4s.build
    end
  end

  def create
    @custom_page4 = @event.custom_page4s.build(custom_page_params)
    if @custom_page4.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      else
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      end
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @custom_page4.update_attributes(custom_page_params)
      redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
    else
      render :action => "edit"
    end
  end

  def show
    render :layout => false
  end

  def destroy
    if @custom_page4.destroy
      redirect_to admin_event_custom_page4s_path(:event_id => @custom_page4.event_id)
    end
  end

  protected

  def custom_page_params
    params.require(:custom_page4).permit!
  end
  def check_user_role
    if (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])) #current_user.has_role? :db_manager 
      redirect_to admin_dashboards_path
    end  
  end
end
