class Api::V1::PasswordsController < ApplicationController
	skip_before_action :load_filter
	skip_before_action :authenticate_user!
	respond_to :json

	def index
		if params[:mobile_application_preview_code].present? 
      mobile_application = MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    elsif params[:mobile_application_code].present?
			mobile_application = MobileApplication.where('submitted_code =? or preview_code =?', params['mobile_app_code'], params['mobile_app_code']).first
		end
		# mobile_application = MobileApplication.where('submitted_code =? or preview_code =?', params['mobile_app_code'], params['mobile_app_code']).first
		if mobile_application.present?
			event = Event.find_by_id(params[:event_id]) if params[:event_id].present?
			event_ids = event.present? ? [event.id] : mobile_application.events.pluck(:id) rescue []
			invitees = Invitee.where("event_id IN(?) and email =?", event_ids, params['email'])
			if invitees.present?
				invitee = invitees.first
				if invitee.email != 'preview@previewapp.com'
					pwd = invitee.email.first(4) rescue rand.to_s[2..5]
					pwd += rand.to_s[2..7]
					invitees.map{|n| n.update_attributes(:password => pwd, :invitee_password => pwd)}
				end
					UserMailer.send_password_invitees(invitee).deliver_now
					render :status => 200, :json => {:status => "Success", :message => "Email Sent Successfully."}
			else
				render :status => 200, :json => {:status => "Failure", :message => "Invitee not found."}
			end
		else
			render :status => 200, :json => {:status => "Failure", :message => "Mobile Application not found."}
		end
	end
end
