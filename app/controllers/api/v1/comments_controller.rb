class Api::V1::CommentsController < ApplicationController
	respond_to :json 
	def create
		conversation = Conversation.find_by_id(params[:commentable_id])
		if conversation.present?
			
			# comment = conversation.comments.new(user_id: mobile_current_user.id, description: params[:description])
			comment = conversation.comments.new(:user_id => params[:user_id], :description => params[:description], :commentable_id => params[:commentable_id], :commentable_type => params[:commentable_type])
			if comment.save
				invitee = Invitee.find_by_id(params[:user_id])
				username = invitee.name_of_the_invitee 
				updated_at_with_tmz = comment.updated_at.strftime("%Y %b %d at %H:%M %p (GMT %:z)")
				created_at_with_tmz = comment.created_at.strftime("%Y %b %d at %H:%M %p (GMT %:z)")
   			year = Time.now.strftime("%Y") + " "
   			formatted_updated_at_with_event_timezone = comment.formatted_updated_at_with_event_timezone
   			formatted_created_at_with_event_timezone = comment.formatted_created_at_with_event_timezone		
				render :status=>200,:json=>{:status=>"Success",:message=>"comment Created Successfully.", "id" => comment.id,  "commentable_id" => params[:commentable_id], "commentable_type" => params[:commentable_type], "user_id" => params[:user_id], "description" => params[:description], "created_at" => comment.created_at, "updated_at" => comment.updated_at, "comment_count" => conversation.comments.count, "user_name" => username, "formatted_updated_at_with_event_timezone" => formatted_updated_at_with_event_timezone, "formatted_created_at_with_event_timezone" => formatted_created_at_with_event_timezone}
			else
				render :status=>406,:json=>{:status=>"Failure",:message=>"You need to pass these values: #{comment.errors.full_messages.join(" , ")}" }
			end
		else
			render :status=>406,:json=>{:status=>"Failure",:message=>"Conversation Not Found."}
		end
	end 
end
