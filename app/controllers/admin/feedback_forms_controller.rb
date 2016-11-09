class Admin::FeedbackFormsController < ApplicationController
	layout 'admin'
  before_filter :authenticate_user
  before_action :find_event
  
	def index
    @feedback_forms = FeedbackForm.where(event_id: params[:event_id])
	end

	def new
		@feedback_form = @event.feedback_forms.build
	end

	def create
		@feedback_form = @event.feedback_forms.build(feedback_form_params)
    if @feedback_form.save
      redirect_to admin_event_feedback_forms_path(:event_id => @feedback_form.event_id)
    else
      render :action => 'new'
    end
	end

	def edit
		@feedback_form = FeedbackForm.find(params[:id])
	end

  def update
    @feedback_form = FeedbackForm.find(params[:id])
    if params[:feedback_form_status].present? and params[:feedback_form_status] =="true"
      @feedback_form.update_attribute('status',params[:status])
      redirect_to admin_event_feedback_forms_path(:event_id => @feedback_form.event_id)
	  elsif @feedback_form.update_attributes(feedback_form_params)
      redirect_to admin_event_feedback_forms_path(:event_id => @feedback_form.event_id)
    else
      render :action => "edit"
    end
	end

  def show
  	@feedback_form = FeedbackForm.find(params[:id])
  end

  def destroy
  	@feedback_form = FeedbackForm.find(params[:id])
    if @feedback_form.destroy
      redirect_to admin_event_feedback_forms_path(:event_id => @feedback_form.event_id)
    end
  end

	protected

	def find_event
		@event = Event.find(params[:event_id])
	end

  def feedback_form_params
    params.require(:feedback_form).permit!
  end
end