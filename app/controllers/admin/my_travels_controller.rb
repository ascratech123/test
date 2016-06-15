class Admin::MyTravelsController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  #before_filter :get_invitee_name, :only => [:index]

  def index
    @my_travels = @my_travels.paginate(:page => params[:page], :per_page => 10)
  end
  def new
    @my_travel = @event.my_travels.build
    @import = Import.new if params[:import].present?
  end
  def create
    @my_travel = MyTravel.find_or_initialize_by(:event_id => @event.id,:invitee_id => params[:my_travel][:invitee_id])
    @my_travel.attach_file = params[:my_travel][:attach_file]
    @my_travel.attach_file_1_name = params[:my_travel][:attach_file_1_name]
    @my_travel.attach_file_2 = params[:my_travel][:attach_file_2] if params[:my_travel][:attach_file_2].present?
    @my_travel.attach_file_2_name = params[:my_travel][:attach_file_2_name] if params[:my_travel][:attach_file_2_name].present?
    @my_travel.attach_file_3 = params[:my_travel][:attach_file_3] if params[:my_travel][:attach_file_3].present?
    @my_travel.attach_file_3_name = params[:my_travel][:attach_file_3_name] if params[:my_travel][:attach_file_3_name].present?
    @my_travel.attach_file_4 = params[:my_travel][:attach_file_4] if params[:my_travel][:attach_file_4].present?
    @my_travel.attach_file_4_name = params[:my_travel][:attach_file_4_name] if params[:my_travel][:attach_file_4_name].present?
    @my_travel.attach_file_5 = params[:my_travel][:attach_file_5] if params[:my_travel][:attach_file_5].present?
    @my_travel.attach_file_5_name = params[:my_travel][:attach_file_5_name] if params[:my_travel][:attach_file_5_name].present?
    if @my_travel.save
      redirect_to admin_event_my_travels_path(:event_id => @event.id)
    else
      render :action => 'new'
    end
  end

  def edit
    
  end
  def update
   if @my_travel.update_attributes(my_travel_params)
      redirect_to admin_event_my_travels_path(:event_id => @event.id)
    else
      render :action => "edit"
    end 
  end

  def destroy
    if @my_travel.destroy
      redirect_to admin_event_my_travels_path(:event_id => @event.id)
    end
  end
  


  protected

  def my_travel_params
    params.require(:my_travel).permit!
  end

end
