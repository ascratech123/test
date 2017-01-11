class Admin::EdmsController < ApplicationController
  layout 'admin'
  Mime::Type.register "image/gif", :gif
  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role
  before_filter :find_edms
  before_action :find_fields_from_database, :only => [:new, :edit, :update, :create]
  before_filter :check_smtp_setting, :only => [:new, :index]

  def index
    @edms = @edms.paginate(page: params[:page], per_page: 10)
  end

  def new
    @edm = @campaign.edms.build
  end

  def create
    @edm = @campaign.edms.build(edm_params)
    if @edm.save
      if params[:commit].present? and params[:commit] == "NEXT"
        redirect_to edit_admin_event_campaign_edm_path(:event_id => @campaign.event_id, :campaign_id => @edm.campaign_id,:id => @edm.id,:next => params[:commit])
      else
        # redirect_to admin_event_campaign_edms_path(:event_id => @campaign.event_id, :campaign_id => @edm.campaign_id)
        redirect_to admin_event_campaign_edm_path(@edm.campaign.event_id,@edm.campaign_id,@edm.id)
      end
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if params[:broadcast_date].present?
      @edm.assign_attributes(edm_params) #if params[:edm][:group_type].present? and params[:edm][:group_type] == "apply filter"
      @edm.set_time(params[:edm][:start_date_time],params[:edm][:start_time_hour],params[:edm][:start_time_minute],params[:edm][:start_time_am]) if (params[:edm][:edm_broadcast_value].present? and params[:edm][:edm_broadcast_value] == "scheduled")
      # @edm.edm_broadcast_time = Time.now if (params[:edm][:edm_broadcast_value].present? and params[:edm][:edm_broadcast_value] == "now")
      # @edm.edm_broadcast_value, @edm.group_type, @edm.flag, @edm.database_email_field = params[:edm][:edm_broadcast_value], params[:edm][:group_type], "1", params[:edm][:database_email_field]
      # @edm.group_id = params[:edm][:group_id] if params[:edm][:group_type].present? and params[:edm][:group_type] != "all"
      # @edm.group_id = @event.groupings.where(name:"Default Group").first.id if params[:edm][:group_type].present? and params[:edm][:group_type] == "all" and @event.groupings.present?
      @edm.save
      @edm.send_mail_to_invitees if @edm.edm_broadcast_value == 'now' #and @edm.sent == 'no'
      # @edm.sent_mail(@edm,@event)
    else
      @edm.update_attributes(edm_params)
    end
      if @edm.errors.blank?
        if params[:commit].present? and params[:commit] == "NEXT"
          redirect_to edit_admin_event_campaign_edm_path(:event_id => @campaign.event_id, :campaign_id => @edm.campaign_id,:id => @edm.id,:next => params[:commit])
        elsif params[:commit].present? and params[:commit] == "SEND"
          redirect_to admin_event_campaign_edms_path(:event_id => @campaign.event_id, :campaign_id => @edm.campaign_id)
        else
          redirect_to admin_event_campaign_edm_path(@edm.campaign.event_id,@edm.campaign_id,@edm.id)
        end
      else
        render :action => "edit"
      end
  end

  def show
    if params[:email_open].present?
      edm = Edm.find(params[:id])
      email_sent = EdmMailSent.where(:edm_id => edm.id, :email => params[:user_email]).first
      email_sent.update_column(:open, 'yes') if email_sent.present?
      respond_to do |format|
        format.html{}
        format.gif{send_data open("#{Rails.root}/public/Transparent.gif", "rb") { |f| f.read }}
      end
    elsif params[:unsubscribe].present?
      unsubscribe_user = Unsubscribe.where(:event_id => params[:event_id],:edm_id => params[:id],:email => params[:user_email]).first
      unsubscribe_user.update_column('unsubscribe',params[:unsubscribe])
      redirect_to admin_unsubscribes_success_path
    else
      render :layout => false
    end
  end

  def destroy
    if @edm.destroy
      redirect_to admin_event_campaign_edms_path(:event_id => @campaign.event_id, :campaign_id => @edm.campaign_id)
    end
  end

  protected

  def find_fields_from_database
    @fields = Grouping.get_default_grouping_fields(@event) if @event.invitee_structures.present? and @event.groupings.present?
  end

  def find_edms
    @campaign = @event.campaigns.find_by_id(params[:campaign_id])
    if @campaign.present?  
      @edms = @campaign.edms
      @edm = @edms.find_by_id(params[:id]) if params[:id].present? and @edms.present?
    end  
  end

  def check_smtp_setting
    event = @campaign.event
    licensee_admin = event.get_licensee_admin
    smtp_setting = licensee_admin.smtp_setting
    if smtp_setting.blank?
      redirect_to new_admin_smtp_setting_path(:smtp_url => params[:smtp_url])
    end
  end

  def edm_params
    params.require(:edm).permit!
  end
end