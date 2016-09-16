class Admin::UserQuizzesController < ApplicationController
  layout 'admin'
  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features

  def index
    respond_to do |format|
      format.html  
      format.xls do
        method_allowed = [:Timestamp, :email_id, :first_name, :last_name, :question, :user_answer, :correct_answer]
        send_data @user_quizes.includes(:quiz).to_xls(:methods => method_allowed)
      end
    end
  end

  private

  def find_features
    @quizes = @event.quizzes
    @user_quizes = UserQuiz.where(:quiz_id => @quizes.pluck(:id))# if params[:format].present?
  end

end