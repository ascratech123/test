class Api::V1::ConversationsController < ApplicationController
  respond_to :json 
  def create
    event = Event.find_by_id(params[:event_id])
    if event.present?
      if params[:image].present?
        conversation = event.conversations.new(:description => params[:description], :image => params[:image].first, :user_id => params[:user_id] ) 
      else
        conversation = event.conversations.new(:description => params[:description], :user_id => params[:user_id] ) 
      end
      if conversation.save
        render :status=>406,:json=>{:status=>"Success",:message=>"Conversation Created Successfully.", :id => conversation.id, :status => conversation.status, :updated_at => conversation.updated_at }
      else
        render :status=>406,:json=>{:status=>"Failure",:message=>"You need to pass these values: #{conversation.errors.full_messages.join(" , ")}" }
      end
    else
      render :status=>406,:json=>{:status=>"Failure",:message=>"Event Not Found."}
    end
  end

end
