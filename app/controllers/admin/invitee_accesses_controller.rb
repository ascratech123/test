class Admin::InviteeAccessesController < ApplicationController
  layout 'admin'
  #load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role#, :find_features
  before_filter :find_invitee_access, :except => [:index]

  def index
    @venue_sections = @event.venue_sections if @event.venue_sections.present?
    if @venue_sections.present? and params[:sample_download].present?
      respond_to do |format|
        format.xls do
          array = ["Email"]
          array_venue_sections = @event.venue_sections.where(:default_access => "no").pluck(:name)
          array = array + array_venue_sections
          @export_data = [array]
          send_data @export_data.to_reports_xls
        end
      end
    else
      @invitee_accesses = InviteeAccess.all.paginate(:page => params[:page], :per_page => 10) 
    end 
  end
  
  def new
    @invitee_access = InviteeAccess.new
    @import = Import.new if params[:import].present?
  end

  def create
    if params[:invitee_access][:venue_section_id].present?
      params[:invitee_access][:venue_section_id].each do |venue_section_id|
        @invitee_access = InviteeAccess.new()
        @invitee_access.invitee_id,@invitee_access.venue_section_id,@invitee_access.event_id = params[:invitee_access][:invitee_id],venue_section_id,params[:invitee_access][:event_id]
        @invitee_access.save
      end
      if @invitee_access.errors.blank?
        redirect_to admin_event_invitee_accesses_path(:event_id => @event.id)
      else
        @invitees = @event.invitees rescue []
        @venue_sections = @event.venue_sections.where(:default_access => "no") rescue []
        render :action => 'new'
      end
    else
      # @invitee_access = InviteeAccess.new
      # @invitees = @event.invitees rescue []
      # @venue_sections = @event.venue_sections.where(:default_access => "no") rescue []
      render :action => 'new'
    end
  end

  def edit
    @invitee_access = InviteeAccess.find(params[:id])
    # @invitees = @event.invitees rescue []
    # @venue_sections = @event.venue_sections.where(:default_access => "no") rescue []
  end

  def update
    if params[:invitee_access][:venue_section_id].present?
      params[:invitee_access][:venue_section_id].each do |venue_section_id|
        @invitee_access = InviteeAccess.find(params[:id])
        @invitee_access.update_column(:invitee_id,params[:invitee_access][:invitee_id]) if params[:invitee_access][:invitee_id].present?
        @invitee_access.update_column(:venue_section_id,venue_section_id) if venue_section_id.present? 
      end
      if @invitee_access.errors.blank?
        redirect_to admin_event_invitee_accesses_path(:event_id => @event.id)
      else
        render :action => "edit"
      end
    end
  end

  def show
  end

  def destroy
    @invitee_access = InviteeAccess.find(params[:id])
    if @invitee_access.destroy
      redirect_to admin_event_invitee_accesses_path(:event_id => @event.id)
    end
  end

  protected
    def invitee_access_params
      params.require(:invitee_access).permit!
    end
    def find_invitee_access
      @invitee_access = InviteeAccess.new if params[:action].present? and params[:action] == "create"
      @invitees = @event.invitees rescue []
      @venue_sections = @event.venue_sections.where(:default_access => "no") rescue []
    end
end
