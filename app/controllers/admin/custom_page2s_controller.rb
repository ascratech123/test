class Admin::CustomPage2sController < ApplicationController
  layout 'admin'
  load_and_authorize_resource :except => [:create]
  before_filter :authenticate_user, :authorize_event_role, :find_features

  def index
    # @custom_pages = @custom_page2s.paginate(page: params[:page], per_page: 10)
    if @event.present? and @event.custom_page2s.present?
      redirect_to edit_admin_event_custom_page2_path(:event_id => params[:event_id],:id => @event.custom_page2s.last.id)
    else
      redirect_to new_admin_event_custom_page2_path(:event_id => params[:event_id])
    end
  end

  def new
    if @event.present? and @event.custom_page2s.present?
      redirect_to edit_admin_event_custom_page2_path(:event_id => params[:event_id],:id => @event.custom_page2s.last.id)
    else
      @custom_page2 = @event.custom_page2s.build
    end
  end

  def create
    @custom_page2 = @event.custom_page2s.build(custom_page_params)
    if @custom_page2.save
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
    if @custom_page2.update_attributes(custom_page_params)
      redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
    else
      render :action => "edit"
    end
  end

  def show
    render :layout => false
  end

  def destroy
    if @custom_page2.destroy
      redirect_to admin_event_custom_page2s_path(:event_id => @custom_page2.event_id)
    end
  end

  protected

  def custom_page_params
    params.require(:custom_page2).permit!
  end
end
