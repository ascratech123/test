class Admin::SponsorsController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  

	def index
    @sponsors = Sponsor.search(params, @sponsors) if params[:search].present?
	end

	def new
		@sponsor = @event.sponsors.build
    # @sponsor.images.build
	end

	def create
		@sponsor = @event.sponsors.build(sponsor_params)
    if @sponsor.save
      redirect_to admin_event_sponsors_path(:event_id => @sponsor.event_id)
    else
        # @sponsor.images.build if @sponsor.images.count == 0
      render :action => 'new'
    end
	end

	def edit
    # @sponsor.images.build if @sponsor.images.count == 0
	end

	def update
		if @sponsor.update_attributes(sponsor_params)
      redirect_to admin_event_sponsors_path(:event_id => @sponsor.event_id)
    else
      # @sponsor.images.build if @sponsor.images.count == 0
      render :action => "edit"
    end
	end

	def show
  end

  def destroy
    if @sponsor.destroy
      redirect_to admin_event_sponsors_path(:event_id => @sponsor.event_id)
    end
  end

	protected
  
  def sponsor_params
    params.require(:sponsor).permit!
  end
end
