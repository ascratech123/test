class Admin::GroupingsController < ApplicationController
  layout 'admin'
  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_action :set_grouping_fields_validations, :only => [:new, :edit, :update, :create]
  before_action :find_grouping_data, :only => [:index, :show]
  
  def index
    if params[:format].present?
      respond_to do |format|
        format.html  
        format.xls do
          method_allowed = []
          for invitee in @invitee_datum
            arr = @only_columns.map{|c| invitee.attributes[c]}
            @export_array << arr
          end
          send_data @export_array.to_reports_xls
        end
      end
    else
      redirect_to admin_event_invitee_structures_path(:event_id => @event.id)
    end
  end

  def new
    @grouping = @event.groupings.new
  end

  def create
    @grouping = @event.groupings.build(grouping_params)
    if @grouping.save
      redirect_to admin_event_invitee_structures_path(:event_id => @event.id)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @grouping.update(grouping_params)
      redirect_to admin_event_invitee_structures_path(:event_id => @event.id)
    else
      render :action => "edit"
    end
  end

  def destroy
    if @grouping.destroy
      redirect_to admin_event_invitee_structures_path(:event_id => @event.id)
    end
  end

  def show
    respond_to do |format|
      format.html  
      format.xls do
        method_allowed = []
        for invitee in @invitee_datum
          arr = @only_columns.map{|c| invitee.attributes[c]}
          @export_array << arr
        end
        send_data @export_array.to_reports_xls, filename: "#{@grouping.name.gsub(' ', '_') rescue 'Grouping'}.xls"
      end
    end
  end

  private

  def set_grouping_fields_validations
    @fields = Grouping.get_default_grouping_fields(@event)
    @validations = Grouping.default_validation
  end

  def find_grouping_data
    if params[:format].present?
      @grouping = Grouping.where(:event_id => @event.id, :id => params[:id]).last
      @invitee_structure = @event.invitee_structures.last
      columns = @invitee_structure.attributes.except('id','created_at','updated_at','event_id','uniq_identifier')
      @only_columns = @invitee_structure.get_selected_column
      header_columns = @only_columns.map{|c| columns[c]}.compact
      @invitee_datum = @grouping.get_search_data_count(InviteeDatum.where(:invitee_structure_id => @invitee_structure.id))
      @export_array = [header_columns]
    end  
  end
  
  def grouping_params
    params[:grouping].permit!
  end

end