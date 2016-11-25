class Admin::CoursesController < ApplicationController
  layout 'admin'
  before_filter :get_event

  def index
    @courses = @event.courses
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      else
        redirect_to admin_event_courses_path(:event_id => @course.event_id)
      end
    else
      render :action => 'new'
    end
  end

  def show
    @course = Course.find(params[:id])
  end

  def edit
    @course = Course.find(params[:id])
  end

  def update
    @course = Course.find(params[:id])
    if @course.update_attributes(course_params)
      redirect_to admin_event_courses_path(:event_id => @course.event_id)
    else
      render :action => "edit"
    end
  end

  def destroy
    @course = Course.find(params[:id])
    @course.destroy
    redirect_to admin_event_courses_path(:event_id => @course.event_id)
  end

  protected

  def course_params
    params.require(:course).permit!
  end

  def get_event
    @event = Event.find(params[:event_id]) if params[:event_id].present?
  end

end
