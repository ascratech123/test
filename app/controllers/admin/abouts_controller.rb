class Admin::AboutsController < ApplicationController

	layout 'admin'
	before_filter :authenticate_user, :find_event

	def index
	end

	def new
		if @event.about.present?
			redirect_to edit_admin_event_about_path(:event_id => @event.id, :id => @event.id)
		end
	end

	def edit
	end
	
	def create
		if @event.update_attributes(events_params)
			# redirect_to new_admin_event_about_path(@event)
			redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application.id, :type => "show_content")
		else
			render :action => "new"
		end
	end

	def destroy
	end

	def show
	end

	protected

	def find_event
		@event = Event.find_by_id(params[:event_id])
	end

	def events_params
    params.require(:event).permit!.except(:features)
  end

end
