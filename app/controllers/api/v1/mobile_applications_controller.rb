class Api::V1::MobileApplicationsController < ApplicationController

  skip_before_action :load_filter
  skip_before_action :authenticate_user!
  respond_to :json

  def show
    @mobile_application = MobileApplication.find_by_submitted_code(params[:id]) || MobileApplication.find_by_preview_code(params[:id]) || MobileApplication.find_by_id(params[:id])
    if @mobile_application.present?
      create_device_token
      render :status => 200, :json => {:status => "Success", :mobile_application => @mobile_application.as_json(:only => [:id,:login_background_color,:message_above_login_page,:registration_message, :registration_link, :login_button_color, :login_button_text_color, :listing_screen_text_color, :social_media_status, :visitor_registration, :choose_home_page, :home_page_event_id], :methods => [:app_icon_url, :splash_screen_url, :login_background_url, :listing_screen_background_url, :visitor_registration_background_image_url, :visitor_registration_back_color ]) }
    else
      render :status => 200, :json => {:status => "Failure", :message => "Mobile Application Not Found."}
    end
  end

  protected

  def create_device_token
    if (params[:device_token].present? and params[:platform].present?) and @mobile_application.present?
      device = Device.where(:token => params[:device_token]).first
      if device.present?
        device.update(:mobile_application_id => @mobile_application.id, :enabled => 'true')
      else
        Device.create(:token => params[:device_token], :platform => params[:platform],:mobile_application_id => @mobile_application.id, :enabled => 'true')
      end
    end
    return
  end
  
end