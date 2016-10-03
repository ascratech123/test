class Api::V1::InviteeChatsController < ApplicationController
	respond_to :json 

	def index
		if params[:event_id] and params[:invitee_id].present?
			@event = Event.find(params[:event_id])
			@chats = @event.chats.where("sender_id = ? or member_ids = ?",params[:invitee_id],params[:invitee_id]).order(created_at: :desc)
			if @chats.present?
				#@recieve_chats_invitee_ids = @chats.pluck(:sender_id).uniq		
				#@send_chats_invitee_ids = @chats.pluck(:member_ids).uniq.map { |x| x.to_i }
				#@invitee_list = @recieve_chats_invitee_ids + @send_chats_invitee_ids 
				@invitees_list = @chats.pluck(:sender_id,:member_ids).flatten.map { |x| x.to_i}.uniq
				@invitees = Invitee.where("id IN (?)",@invitees_list)
				invitees = []
				@invitees.each do |invitee|
					data = {}
					data["id"] = invitee.id
					data["first_name"] = invitee.first_name
					data["last_name"] = invitee.last_name
					data["profile_picture"] = invitee.profile_picture
					data["unread_chat_count"]= invitee.unread_chat_count(params[:invitee_id])
					data["created_at_with_event_timezone"] = invitee.created_at_with_event_timezone 
					data["updated_at_with_event_timezone"] = invitee.updated_at_with_event_timezone
					invitees << data
				end	
				render :status => 200, :json => {:status => "Success",:invitees => invitees}
				#render :status => 200, :json => {:status => "Success",:invitees => @invitees.as_json(:only =>[:id,:first_name,:last_name],:except => [:created_at, :updated_at], :methods => [:profile_picture,:unread_chat_count,:created_at_with_event_timezone, :updated_at_with_event_timezone])}
			else
				render :status=>200, :json=>{:status=>"Failure",:message=>"Invitees Not Found."}
			end	 
		else
			render :status=>200, :json=>{:status=>"Failure",:message=>"please provide required paramters."}
		end	
	end
end