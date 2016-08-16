class Admin::VenueSectionsController < ApplicationController
  layout 'admin'
  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features

  def index
    @venue_sections = @event.venue_sections.paginate(:page => params[:page], :per_page => 10)      
  end
  
  def new
    @venue_section = @event.venue_sections.build
    @import = Import.new if params[:import].present?
  end

  def create
    @venue_section = @event.venue_sections.build(venue_section_params)
    if @venue_section.save
      redirect_to admin_event_venue_sections_path(:event_id => @event.id)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @venue_section.update_attributes(venue_section_params)
      @venue_section.update_attribute(:default_access, nil) if params[:venue_section][:default_access].blank? 
      redirect_to admin_event_venue_sections_path(:event_id => @event.id)
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @venue_section.destroy
      redirect_to admin_event_venue_sections_path(:event_id => @event.id)
    end
  end

  protected
    def venue_section_params
      params.require(:venue_section).permit!
    end
end
