class Admin::ExportQrCodesController < ApplicationController

	before_filter :find_event, :change_format

	def index
		if params[:export].present?
      @qr_codes = @event.analytics.where.not(viewable_url: [nil, ""])
      respond_to do |format|
        format.xls do
          only_columns = [:viewable_url]
          method_allowed = [:invitee_email]
          send_data @qr_codes.to_xls(:only => only_columns, :methods => method_allowed)
        end
      end
    end
	end

	private

	def find_event
    @event = Event.find_by_id(params[:event_id])
  end

  def change_format
    request.format = "xls"
  end

end
