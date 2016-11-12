class Api::V1::EventsController < ApplicationController
 require "sync_mobile_data"
 
  respond_to :json
  before_filter :check_date, :only => :index

  skip_filter :find_clients, :set_current_user
  skip_filter :telecaller_is_login
  caches_action :index, :cache_path => Proc.new { |c| c.params }, :expires_in => 2.minutes.to_i

  def index
    # mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    # submitted_app = "Yes" if params[:mobile_application_code].present? 
    if params[:mobile_application_preview_code].present?
      mobile_application = MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    elsif params[:mobile_application_code].present?
      mobile_application = MobileApplication.where('submitted_code =? or preview_code =?', params[:mobile_application_code], params[:mobile_application_code]).first
    end

    submitted_app = "Yes" if params[:mobile_application_code].present? and mobile_application.submitted_code == params[:mobile_application_code]
    if mobile_application.present?
#======mine
#      sync_time = Time.now.to_s
#      start_event_date = params[:previous_date_time].present? ? (params[:previous_date_time]) : "01/01/1990 13:26:58".to_time.utc
#      end_event_date = Time.now + 2.minutes
#=======
      sync_time = Time.now.utc.beginning_of_minute.to_s
      start_event_date = params[:previous_date_time].present? ? (params[:previous_date_time]) : "01/01/1990 13:26:58".to_time.utc
      end_event_date = Time.now.utc + 2.minutes
#>>>>>>> .r4012
      allow_ids = []
      invitee = Invitee.find_by_key(params[:key])
      if invitee.present?
        submitted_app = ((params[:mobile_application_code].present? and mobile_application.submitted_code == params[:mobile_application_code]) ? "Yes" : "No")
        allow_ids = invitee.get_event_id_api(mobile_application.submitted_code,submitted_app,start_event_date,end_event_date)
      end  
      data = SyncMobileData.sync_records(start_event_date, end_event_date, mobile_application.id, mobile_current_user,submitted_app) 
      render :staus => 200, :json => {:status => "Success", :sync_time => sync_time, :application_type => mobile_application.application_type, :social_media_status => mobile_application.social_media_status, :login_at_after_splash => mobile_application.login_at, :event_ids => allow_ids, :data => data }
    else
      render :status => 200, :json => {:status => "Failure", :message => "Provide mobile application preview code or submitted code."}
    end 
  end 
  
  def create
    chanages_done = []
    params[:platform] = params[:platform].present? ? params[:platform] : "" 
    params["data"].each do |key, value|
      chanages_done = SyncMobileData.select_model(key,value,params[:platform])
    end 
    render :status => 200, :json => {:status => "Success", :response => chanages_done}
    return
  end

  def delete_mobile_data
    deleted_id = [] 
    params["data"].each do |key, value|
      case key
        when "Like"
          deleted_id << SyncMobileData.delete_record(value,"Like")
        when "Favorite"
          deleted_id << SyncMobileData.delete_record(value,"Favorite")
      end
    end 
    render :status => 200, :json => {:status => "Success", :deleted_id => deleted_id.flatten!}
    return
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
end
