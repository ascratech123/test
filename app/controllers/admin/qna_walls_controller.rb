class Admin::QnaWallsController < ApplicationController
  
  layout 'admin'
  before_filter :authenticate_user, :find_event
  
	def new
		@qna_wall = QnaWall.new
	end
	
  def create
		@qna_wall = QnaWall.new(qna_wall_params)
    if @qna_wall.save
      redirect_to admin_event_qnas_path(:event_id => @qna_wall.event_id)
    else
      render :action => 'new'
    end
	end

	def edit
  	@qna_wall = QnaWall.find(params[:id])
  end
  
  def update
    @qna_wall = QnaWall.find(params[:id])
    if @qna_wall.update_attributes(qna_wall_params)
      redirect_to admin_event_qnas_path(:event_id => @qna_wall.event_id)
    else
      render :action => "edit"
    end
  end
	
  protected
	
  def find_event
		@event = Event.find(params[:event_id])
	end	
	
	def qna_wall_params
    params.require(:qna_wall).permit!
  end

end