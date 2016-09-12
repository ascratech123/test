class Admin::BadgePdfsController < ApplicationController
  
  layout 'admin'
  before_filter :authenticate_user, :find_event
  
	def new
		@badge_pdf = BadgePdf.new
	end

	def create
		@badge_pdf = BadgePdf.new(badge_pdf_params)
    if @badge_pdf.save
      redirect_to admin_event_qr_scanner_details_path(:event_id => @badge_pdf.event_id)
    else
      render :action => 'new'
    end
	end

	def edit
  	@badge_pdf = BadgePdf.find(params[:id])
  end

  def update
    @badge_pdf = BadgePdf.find(params[:id])
    if @badge_pdf.update_attributes(badge_pdf_params)
      redirect_to admin_event_qr_scanner_details_path(:event_id => @badge_pdf.event_id)
    else
      render :action => "edit"
    end
  end

	protected

	def find_event
		@event = Event.find(params[:event_id])
	end	
	
	def badge_pdf_params
    params.require(:badge_pdf).permit!
  end
end

