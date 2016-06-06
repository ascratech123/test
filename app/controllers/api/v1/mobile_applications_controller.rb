class Api::V1::MobileApplicationsController < ApplicationController

  skip_before_action :load_filter
  skip_before_action :authenticate_user!
  respond_to :json

  def show
    mobile_application = MobileApplication.find_by_submitted_code(params[:id]) || MobileApplication.find_by_preview_code(params[:id]) || MobileApplication.find_by_id(params[:id])
    if mobile_application.present?
      render :status => 200, :json => {:status => "Success", :mobile_application => mobile_application.as_json(:only => [:id,:login_background_color,:message_above_login_page,:registration_message, :registration_link, :login_button_color, :login_button_text_color, :listing_screen_text_color, :social_media_status], :methods => [:app_icon_url, :splash_screen_url, :login_background_url, :listing_screen_background_url ]) }
    else
      render :status => 200, :json => {:status => "Failure", :message => "Mobile Application Not Found."}
    end
  end
end