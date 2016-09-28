class Admin::ConversationWallsController < ApplicationController
  
  layout 'admin'
  before_filter :authenticate_user, :find_event
  
	def new
		@conversation_wall = ConversationWall.new
	end
	
  def create
		@conversation_wall = ConversationWall.new(conversation_wall_params)
    if @conversation_wall.save
      redirect_to edit_admin_event_conversation_wall_path(:event_id => @conversation_wall.event_id,:id =>@conversation_wall.id)
    else
      render :action => 'new'
    end
	end

	def edit
  	@conversation_wall = ConversationWall.find(params[:id])
  end
  
  def update
    @conversation_wall = ConversationWall.find(params[:id])
    if @conversation_wall.update_attributes(conversation_wall_params)
      redirect_to edit_admin_event_conversation_wall_path(:event_id => @conversation_wall.event_id,:id =>@conversation_wall.id)
    else
      render :action => "edit"
    end
  end
	
  protected
	
  def find_event
		@event = Event.find(params[:event_id])
	end	
	
	def conversation_wall_params
    params.require(:conversation_wall).permit!
  end

end
