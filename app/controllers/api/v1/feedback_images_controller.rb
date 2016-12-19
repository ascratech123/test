class Api::V1::FeedbackImagesController < ApplicationController
  skip_before_action :load_filter
  skip_before_action :authenticate_user!

  respond_to :json 
  def create
    feedback = Feedback.find_by_id(params[:feedback_id])
    if feedback.present?
      if params[:image].present?
        user_feedback = feedback.user_feedbacks.new(:feedback_id => params[:feedback_id], :image => params[:image], :user_id => params[:user_id], :answer => params[:answer], :description => params[:description],:feedback_form_id => params[:feedback_form_id]) 
      else
        user_feedback = feedback.user_feedbacks.new(:feedback_id => params[:feedback_id], :user_id => params[:user_id], :answer => params[:answer], :description => params[:description],:feedback_form_id => params[:feedback_form_id]) 
      end
      if user_feedback.save
        #conversation.update_column('last_interaction_at',conversation.updated_at)
        # render :status=>406,:json=>{:status=>"Success",:message=>"Feedback Image Created", :id => conversation.id, :visible_status => conversation.status, :updated_at => conversation.updated_at, :image_url => conversation.image_url, :company_name => conversation.company_name, :user_name => conversation.user_name, :first_name => conversation.user.first_name, :last_name => conversation.user.last_name, :formatted_created_at_with_event_timezone => conversation.formatted_created_at_with_event_timezone, :formatted_updated_at_with_event_timezone => conversation.formatted_updated_at_with_event_timezone, :last_interaction_at => conversation.last_interaction_at, :actioner_id => conversation.actioner_id}
        render :status=>406,:json=>{:status=>"Success",:message=>"Feedback Image Created"}
      else
        render :status=>406,:json=>{:status=>"Failure",:message=>"You need to pass these values: #{user_feedback.errors.full_messages.join(" , ")}" }
      end
    else
      render :status=>406,:json=>{:status=>"Failure",:message=>"Feedback Not Found."}
    end
  end  
end
