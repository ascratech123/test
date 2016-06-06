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
  end
  def create
    @my_travel = MyTravel.find_or_initialize_by(:event_id => @event.id, :invitee_id => params[:my_travel][:invitee_id])
    @my_travel.attach_file = params[:my_travel][:attach_file]
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

  def get_invitee_name
    @my_travels.each do |my_travel|
      @invitee_name = Invitee.find(my_travel.invitee_id).name_of_the_invitee
      
    end
  end
end
