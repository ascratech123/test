class Admin::InviteeStructuresController < ApplicationController
	layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features, :find_invitee_data
    
  def index
    if @invitee_structure.present?
      @invitee_data = @invitee_structure.invitee_datum
      respond_to do |format|
        if @invitee_structure.present? and params[:sample_download].present?
          format.xls do
            only_columns = @invitee_structure.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier','email_field').map{|k, v| v.to_s.length > 0 ? v.downcase : nil}.compact
            @invitee_structure = InviteeStructure.where(:event_id => @event.id)
            send_data @invitee_structure.to_xls(:only => only_columns)
          end
        else
          # @invitee_data = @invitee_structure.invitee_datum#InviteeStructure.search(params, @invitee_structures) if params[:search].present?
          #@invitee_data = InviteeDatum.search(params, @invitee_data)
          format.html  
          format.xls do
            
          end
        end
      end
    else
      redirect_to new_admin_event_invitee_structure_path(:event_id => params[:event_id])
    end
  end

  def new
    @import = Import.new if params[:import].present?
    if @invitee_structures.present? and @import.blank?
      redirect_to edit_admin_event_invitee_structure_path(:event_id => @event.id, :id => @invitee_structure.id)
    else
      @invitee_structure = @event.invitee_structures.build
    end
  end

  def create
    @invitee_structure = @event.invitee_structures.build(invitee_structure_params)
    if @invitee_structure.save
      redirect_to admin_client_event_path(:client_id => @event.client_id, :id => @event.id)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @invitee_structure.update_attributes(invitee_structure_params)
      redirect_to admin_event_invitee_structures_path(:event_id => @invitee_structure.event_id)
    else
      render :action => "edit"
    end
  end

  def show
    redirect_to edit_admin_event_invitee_structure_path(:event_id => @event.id, :id => @event.invitee_structures.first.id)
  end

  def destroy
    @invitee_data = InviteeDatum.find(params[:id])
    @invitee_structure = @invitee_data.invitee_structure
    if @invitee_data.destroy
      redirect_to admin_event_invitee_structures_path(:event_id => @invitee_structure.event_id)
    end
  end

  protected

  def find_invitee_data
    @invitee_structures = @event.invitee_structures if params[:action] != 'index'
    @invitee_structure = @invitee_structures.first if @invitee_structures.present?
    @groupings = @event.groupings
  end

  def invitee_structure_params
    if params[:invitee_structure].present?
      params.require(:invitee_structure).permit!
    else
      {}
    end
  end

end
