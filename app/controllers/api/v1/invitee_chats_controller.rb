class Api::V1::InviteeChatsController < ApplicationController
	respond_to :json 

	def index
		if params[:event_id] and params[:invitee_id].present?
			@event = Event.find(params[:event_id])
			@chats = @event.chats.where("sender_id = ? or member_ids = ?",params[:invitee_id],params[:invitee_id])
			if @chats.present?
				@recieve_chats_invitee_ids = @chats.pluck(:sender_id).uniq		
				@send_chats_invitee_ids = @chats.pluck(:member_ids).uniq.map { |x| x.to_i }
				#@send_chats_invitee_ids = @send_chats_invitee_ids.map{|val| val.split(',')}.flatten.uniq
				#@send_chats_invitee_ids = @send_chats_invitee_ids.map {|i| i.to_i}
				
				@invitee_list = @recieve_chats_invitee_ids + @send_chats_invitee_ids 
				@invitee_list = @invitee_list.uniq
				@invitees = Invitee.where("id IN (?)",@invitee_list)
				render :status => 200, :json => {:status => "Success",:invitees => @invitees.as_json(:only =>[:id,:first_name,:last_name],:except => [:created_at, :updated_at], :methods => [:profile_picture,:unread_chat_count,:created_at_with_event_timezone, :updated_at_with_event_timezone])}
			else
				render :status=>200, :json=>{:status=>"Failure",:message=>"chat Not Found."}
			end	 
		else
			render :status=>200, :json=>{:status=>"Failure",:message=>"please provide required paramters."}
		end	
	end
end