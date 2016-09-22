class Admin::PollsController < ApplicationController
  layout 'admin'
  # load_and_authorize_resource
  skip_before_filter :authenticate_user, :authorize_event_role, :find_features, :only => [:index]
  skip_before_action :load_filter, :only => [:index] 
  before_filter :authenticate_user, :authorize_event_role, :find_features, :except => [:index]
  before_filter :check_user_role, :except => [:index]
  before_filter :poll_wall_present, :only => [:index]
  before_filter :find_user_polls, :only => [:index, :new]
  # before_action :authenticate_user, :authorize_event_role, :find_features, unless: :abc
  before_filter :find_poll_wall, :only => :index

	def index
    if params[:type] != "public_wall"
      @polls = Poll.search(params, @polls) if params[:search].present?
      respond_to do |format|
        format.html  
        format.xls do
          only_columns = [:question, :option1, :option2, :option3, :option4, :option5, :option6, :status]
          method_allowed = []
          send_data @polls.to_xls(:only => only_columns)
        end
      end
    else
      @polls = @polls.where(:on_wall => "yes")   
      render :layout => false
    end  
  end

	def new
		@poll = @event.polls.build
    @import = Import.new if params[:import].present?
	end

	def create
		@poll = @event.polls.build(poll_params)
    if @poll.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_engagement")
      else
        redirect_to admin_event_polls_path(:event_id => @poll.event_id)
      end
    else
      render :action => 'new'
    end
	end

	def edit
	end

	def update
    if params[:status].present? or params[:on_wall].present? or params[:option_visible].present?
      @poll.update_column(:on_wall, params[:on_wall]) if params[:on_wall].present?
      @poll.change_status(params[:status]) if params[:status].present?
      @poll.update_columns(:option_visible => params[:option_visible], :updated_at => Time.now) if params[:option_visible].present?
      redirect_to admin_event_polls_path(:event_id => @poll.event_id)
    else
  		if @poll.update_attributes(poll_params)
        redirect_to admin_event_polls_path(:event_id => @poll.event_id)
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
        send_data @poll.user_polls.to_xls(:filename => 'user_polls', :methods => method_allowed, :only => only_columns)
      end
    end
  end

  def destroy
    if @poll.destroy
      redirect_to admin_event_polls_path(:event_id => @poll.event_id)
    end
  end

  def details
    Poll.all
    render :layout => false  
  end

	protected

  def find_user_polls
    @user_polls = UserPoll.where(:poll_id => @polls.pluck(:id)) if @polls.present?
  end

  def find_poll_wall
    if params[:type].present?
      @event = Event.find(params[:event_id])
      @polls = @event.polls
    end
  end

  def poll_wall_present
    if params[:type].present? and params[:type] != 'public_wall' or params[:type].blank?
      authenticate_user!
      authorize_event_role
      find_features
    end
  end

  def check_user_role
    if (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])) #current_user.has_role? :db_manager 
      redirect_to admin_dashboards_path
    end  
  end
  
  def poll_params
    params.require(:poll).permit!
  end
end
