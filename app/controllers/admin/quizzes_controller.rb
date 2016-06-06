class Admin::QuizzesController < ApplicationController
	layout 'admin'
  
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :find_user_quizzes, :only => [:index, :new]
  
	def index
    @quizzes = Quiz.search(params, @quizzes) if params[:search].present?
    #@quizzes = @quizzes.paginate(page: params[:page], per_page: 10)
    respond_to do |format|
      format.html  
      format.xls do
        only_columns = [:question, :option1, :option2, :option3, :option4, :option5, :option6, :status]
        method_allowed = []
        send_data @quizzes.to_xls(:only => only_columns)
      end
    end
	end

	def new
		@quiz = @event.quizzes.build
    @import = Import.new if params[:import].present?
	end

	def create
		@quiz = @event.quizzes.build(quizze_params)
    if @quiz.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_engagement")
      else
        redirect_to admin_event_quizzes_path(:event_id => @quiz.event_id)
      end
    else
      render :action => 'new'
    end
	end

	def edit
	end

	def update
    if params[:status].present?
      @quiz.change_status(params[:status])
      redirect_to admin_event_quizzes_path(:event_id => @quiz.event_id)
    else
      if !(quizze_params.key?(:correct_ans_option4) or  quizze_params.key?(:correct_ans_option1) or  quizze_params.key?(:correct_ans_option2) or  quizze_params.key?(:correct_ans_option3) or  quizze_params.key?(:correct_ans_option5) )
        quizze_params[:correct_answer] = nil
      end
  		if @quiz.update_attributes(quizze_params)
        redirect_to admin_event_quizzes_path(:event_id => @quiz.event_id)
      else
        render :action => "edit"
      end
    end
	end

	def show
    respond_to do |format|
      format.html  
      format.xls do
        only_columns = [:answer]
        method_allowed = [:email, :question]
        send_data @quiz.user_quizzes.to_xls(:filename => 'user_quizzes', :methods => method_allowed, :only => only_columns)
      end
    end
  end

  def destroy
    if @quiz.destroy
      redirect_to admin_event_quizzes_path(:event_id => @quiz.event_id)
    end
  end

	protected

  def find_user_quizzes
    @user_quizzes = UserQuiz.where(:quizze_id => @quizzes.pluck(:id)) if @quizzes.present?
  end

  def quizze_params
    params.require(:quiz).permit!
  end
end
