class Admin::QrCodeScannersController < ApplicationController
  layout 'admin/layouts/scanner'

  before_filter :authenticate_user, :authorize_event_role

  def index
    @invitee = @event.invitees.where(:id => params[:invitee_id]).last
  end
end