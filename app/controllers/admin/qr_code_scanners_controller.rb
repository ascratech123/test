class Admin::QrCodeScannersController < ApplicationController
  layout 'admin/layouts/scanner'

  before_filter :authenticate_user, :authorize_event_role

  def index
    
  end
end
