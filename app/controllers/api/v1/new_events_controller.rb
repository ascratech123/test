class Api::V1::NewEventsController < ApplicationController
  require "sync_mobile_data"
 
  respond_to :json
  before_filter :check_date, :only => :index

  def index
    mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    submitted_app = "Yes" if params[:mobile_application_code].present?
    if mobile_application.present?
      sync_time = Time.now.utc.to_s
      start_event_date = params[:previous_date_time].present? ? (params[:previous_date_time]) : "01/01/1990 13:26:58".to_time.utc
      end_event_date = Time.now.utc + 2.minutes
      allow_ids = []
      invitee = Invitee.find_by_key(params[:key]) if params[:key].present?
      if invitee.present?
        submitted_app = (params[:mobile_application_code].present? ? "Yes" : "No")
        allow_ids = invitee.get_event_id_api(mobile_application.submitted_code,submitted_app,start_event_date,end_event_date)
        event_ids = allow_ids
      end 
      all_events = mobile_application.events
      event_ids ||= all_events.pluck(:id)
      if params[:event_id].present?
        if !event_ids.include? params[:event_id].to_i
          render :status => 200, :json => {:message => "Invalid event_id"}
        else
          event_ids = [params[:event_id].to_i]
        end
      else
        if mobile_application.marketing_app_event_id.present?# and event_ids.include?(mobile_application.marketing_app_event_id.to_i)
          event_ids = [mobile_application.marketing_app_event_id.to_i]
        else
          event_ids = get_event_ids(event_ids)
        end
      end
      data = SyncMobileData.sync_records(start_event_date, end_event_date, mobile_application.id, mobile_current_user,submitted_app, event_ids) 
      render :staus => 200, :json => {:status => "Success", :sync_time => sync_time, :application_type => mobile_application.application_type, :social_media_status => mobile_application.social_media_status, :login_at_after_splash => mobile_application.login_at, :event_ids => allow_ids, :data => data, :all_events_data => all_events.as_json(:only => [:id, :event_category], :methods => [:logo_url]) }
    else
      render :status => 200, :json => {:status => "Failure", :message => "Provide mobile application preview code or submitted code."}
    end 
  end 

  protected 

  def check_date
    begin
      Date.parse(params[:previous_date_time]) if params[:previous_date_time].present?
    rescue Exception => e
      render :status => 200, :json => {:status => "Failure", :message => "Provide correct Date Format."}
      return
    end
  end

  def get_event_ids(event_ids)
    hsh = {}
    for event in Event.where(:id => event_ids)
      hsh[event.id] = ((Time.now + event.timezone_offset) - event.start_event_time.strftime("%d %m %Y %H:%M %P").to_datetime).abs
    end
    closest_event_id = hsh.sort_by(&:last).first.first  
    [closest_event_id]
  end
end
