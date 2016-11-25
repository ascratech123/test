class Admin::CourseProvidersController < ApplicationController
  layout 'admin'
  def index
    @event = Event.find(params[:event_id])
    @course_providers = @event.course_providers
  end

  def new
    @course_provider = CourseProvider.new
  end

  def create
    @course_provider = CourseProvider.new(course_provider_params)
    if @course_provider.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      else
        redirect_to admin_event_course_providers_path(:event_id => @course_provider.event_id)
      end
    else
      render :action => 'new'
    end
  end

  def show
    @course_provider = CourseProvider.find(params[:id])
  end

  def edit
    @course_provider = CourseProvider.find(params[:id])
  end

  def update
    @course_provider = CourseProvider.find(params[:id])
    if @course_provider.update_attributes(course_provider_params)
      redirect_to admin_event_course_providers_path(:event_id => @course_provider.event_id)
    else
      render :action => "edit"
    end
  end

  def destroy
    @course_provider = CourseProvider.find(params[:id])
    @course_provider.destroy
    redirect_to admin_event_course_providers_path(:event_id => @course_provider.event_id)
  end

  protected

  def course_provider_params
    params.require(:course_provider).permit!
  end

end
