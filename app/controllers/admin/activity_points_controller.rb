class Admin::ActivityPointsController < ApplicationController
  layout 'admin'
  before_filter :find_activity, :only => [:edit, :update, :destroy]
  before_filter :find_event, :only => [:index, :new, :create]

  def index
    @event = Event.find(params[:event_id])
  	@activity_points = ActivityPoint.all
  end

  def new
    @event = Event.find(params[:event_id])
    @activity_point = @event.activity_points.build
  end

  def create
    @event = Event.find(params[:event_id])
    @activity_point = @event.activity_points.build(activity_point_params)
    if @activity_point.save
      redirect_to admin_event_activity_points_path
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @activity_point.update_attributes(activity_point_params)
      redirect_to admin_event_activity_points_path
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
  	if @activity_point.destroy
      redirect_to admin_event_activity_points_path
    else
      admin_event_activity_points_path
    end
  end

  protected

  def find_activity
    @activity_point = ActivityPoint.find(params[:id])
  end

  def activity_point_params
    params.require(:activity_point).permit!
  end

  def find_event
    @event = Event.find(params[:event_id])
  end

end
