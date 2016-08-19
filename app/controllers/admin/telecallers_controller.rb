class Admin::TelecallersController < ApplicationController
  layout 'admin'

  #skip_before_filter :authenticate_user, :find_event, :only => [:show]
  before_filter :authenticate_user#, :except => [:show]
  #before_filter :telecaller_is_login, :except => [:show]
  before_filter :find_event
  #before_filter :find_default_group, :only => [:new, :show]
  def index
    @telecallers = User.joins(:roles).where('roles.resource_type = ? and resource_id = ? and roles.name = ?', "Event", @event.id, "telecaller").uniq.paginate(page: params[:page], per_page: 10)
  end   

  def new
    @telecaller = User.new
  end


  def create
    @telecaller = User.find_or_initialize_by(:email => params[:user][:email])
    if @telecaller.new_record?
      @telecaller = User.new(telecaller_params)
      @grouping = Grouping.where(:id => params[:user][:assign_grouping])
    else
      @grouping = Grouping.where(:id => params[:user][:assign_grouping])
    end
    @telecaller.status = "active"
    if @telecaller.save
      @telecaller.add_role_to_telecaller(@telecaller,@event)
      @telecaller.add_role :telecaller,@grouping.first
      redirect_to admin_event_users_path(:event_id => @event.id,:role => "all") if params[:get_role].present?
      redirect_to admin_event_users_path(:event_id => @event.id) if (!params[:get_role].present? and !params[:telecaller_index].present?)
      # redirect_to admin_event_telecallers_path(:event_id => @event.id) if params[:telecaller_index].present?
    else
      render :action => 'new'
    end
  end

  def edit
    @telecaller = User.unscoped.find(params[:id])
  end

  def update
    @telecaller = User.unscoped.find(params[:id])
    @grouping = Grouping.where(:id => params[:user][:assign_grouping])
    if @telecaller.update_attributes(telecaller_params)
      @telecaller.add_role :telecaller,@grouping.first
      redirect_to admin_event_users_path(:event_id => @event.id,:role=>"all") if params[:get_role].present?
      redirect_to admin_event_users_path(:event_id => @event.id) if (!params[:get_role].present? and !params[:telecaller_index].present?)
      # redirect_to admin_event_telecallers_path(:event_id => @event.id) if params[:telecaller_index].present?
    else
      render :action => "edit"
    end
  end


  def show
    @telecaller = User.unscoped.find(params[:id])
    @telecaller_accessible_columns = @event.telecaller_accessible_columns.first.accessible_attribute if @event.telecaller_accessible_columns.present?
    @grouping = Grouping.find(@telecaller.assign_grouping) rescue nil
    @groupings = Grouping.with_role(@telecaller.roles.pluck(:name), @telecaller)
    @invitee_structure = @event.invitee_structures.first if @event.invitee_structures.present?
    @invitee_data = @invitee_structure.invitee_datum
    data = Grouping.get_search_data_count(@invitee_data, @groupings) if @groupings.present? and @invitee_data.present?
    @data = data.where(:status => nil).first rescue nil
    callback = data.where("status IN (?) and callback_datetime < ?",["CALL BACK","FOLLOW UP"], (Time.now + 15.minutes).to_formatted_s(:db)) rescue nil
    if callback.present?
      @data = callback.first
      @need_to_call = "true"
    end
    @data = data.find_by_id(session[:current_invitee_datum_id]) if session[:current_invitee_datum_id].present? rescue nil
    session[:current_invitee_datum_id] = @data.id rescue nil
    @invitee_structure = @data.invitee_structure if @data.present?

  end

  # def destroy
  #   @telecaller = User.unscoped.find(params[:id])
  #   if @telecaller.destroy
  #     redirect_to admin_event_telecallers_path(:event_id => @event.id)
  #   end
  # end

  protected

  def telecaller_params
    params.require(:user).permit!
  end

  def find_event
    @event = Event.find(params[:event_id])
  end

  def telecaller_is_login
    if current_user.has_role? :telecaller and params[:action] != "show"
      redirect_to destroy_user_session_path
    end
  end

  def find_default_group
    if @event.invitee_structures.last.present?
      @invitee_structure = @event.invitee_structures.last
      @invitee_datum = (InviteeDatum.where(:invitee_structure_id => @invitee_structure.id))
    end
  end

end
