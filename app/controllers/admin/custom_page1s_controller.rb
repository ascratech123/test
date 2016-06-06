class Admin::CustomPage1sController < ApplicationController
  layout 'admin'
  load_and_authorize_resource :except => [:create]
  before_filter :authenticate_user, :authorize_event_role, :find_features

  def index
    # @custom_pages = @custom_page1s.paginate(page: params[:page], per_page: 10)
    if @event.present? and @event.custom_page1s.present?
      redirect_to edit_admin_event_custom_page1_path(:event_id => params[:event_id],:id => @event.custom_page1s.last.id)
    end
  end

  def new
    if @event.present? and @event.custom_page1s.present?
      redirect_to edit_admin_event_custom_page1_path(:event_id => params[:event_id],:id => @event.custom_page1s.last.id)
    else
      @custom_page1 = @event.custom_page1s.build
    end
  end

  def create
    @custom_page1 = @event.custom_page1s.build(custom_page_params)
    if @custom_page1.save
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
    # @custom_page1 = @event.custom_page1s.last
  end

  def update
    if @custom_page1.update_attributes(custom_page_params)
      redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
    else
      render :action => "edit"
    end
  end

  def show
    #render html: @custom_page1.description.html_safe
    # respond_to do |format|
    #   format.html { render :show => @custom_page1.description.html_safe , :layout => false }
    # end
    render :layout => false
  end

  def destroy
    if @custom_page1.destroy
      redirect_to admin_event_custom_page1s_path(:event_id => @custom_page1.event_id)
    end
  end

  protected

  def custom_page_params
    params.require(:custom_page1).permit!
  end
end