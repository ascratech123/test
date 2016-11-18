class Admin::TelecallerAccessibleColumnsController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features

  def index
   
  end   

  def new
    if @event.telecaller_accessible_columns.present?
      redirect_to edit_admin_event_telecaller_accessible_column_path(:event_id => @event.id, :id => @event.telecaller_accessible_columns.first.id)
    else
      @telecaller_accessible_column = @event.telecaller_accessible_columns.build
      @invitee_structures = @event.invitee_structures.first.attributes.except('id','event_id','created_at','updated_at','uniq_identifier','email_field','parent_id')
    end
  end


  def create
    @telecaller_accessible_column = @event.telecaller_accessible_columns.build(telecaller_accessible_column_params)
    if @telecaller_accessible_column.save
      redirect_to admin_event_telecallers_path(:event_id => @event.id) 
    else
      @invitee_structures = @event.invitee_structures.first.attributes.except('id','event_id','created_at','updated_at','uniq_identifier','email_field','parent_id')
      render :action => 'new'
    end
  end

  def edit
    @invitee_structures = @event.invitee_structures.first.attributes.except('id','event_id','created_at','updated_at','uniq_identifier','email_field','parent_id')
  end

  def update
    if @telecaller_accessible_column.update_attributes(telecaller_accessible_column_params)
      redirect_to admin_event_telecallers_path(:event_id => @event.id)
    else
      @invitee_structures = @event.invitee_structures.first.attributes.except('id','event_id','created_at','updated_at','uniq_identifier','email_field','parent_id')
      render :action => "edit"
    end
  end


  def show

  end

  protected
  def telecaller_accessible_column_params
    if params[:telecaller_accessible_column].present? 
      params.require(:telecaller_accessible_column).permit!
    else
      {"accessible_attribute"=>{}}
    end
  end

end
