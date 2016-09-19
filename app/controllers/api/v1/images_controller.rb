class Api::V1::ImagesController < ApplicationController
  skip_before_action :load_filter
	skip_before_action :authenticate_user!
	respond_to :json
	
	def index
		# mobile_application = MobileApplication.where('submitted_code =? or preview_code =? or id =?', params[:mobile_application_code], params[:mobile_application_code], params["mobile_application_id"]).first
		mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code]) || MobileApplication.find_by_id(params["mobile_application_id"])
		event_status = (params[:mobile_application_code].present? ? ["published"] : ["approved","published"])
		if mobile_application.present?
			events = mobile_application.events 
			event = events.where(:id => params[:event_id], :status => event_status) rescue nil
			if event.present?
				galleries = Image.where(:imageable_id => event.first.id,:imageable_type => "Event") rescue []
				render :staus => 200, :json => {:status => "Success",:galleries => galleries.as_json(:except => [:image_file_name,:image_content_type,:image_file_size,:image_updated_at], :methods => [:image_url]) } rescue []
			else
				render :status => 200, :json => {:status => "Failure", :message => "Event Not Found."}
			end	
		else
			render :status => 200, :json => {:status => "Failure", :message => "Mobile Application Not Found."}
		end	
	end
end
