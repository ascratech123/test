class Admin::EdmsController < ApplicationController
  layout 'admin'
  # load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role
  before_filter :find_edms

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
        redirect_to admin_event_campaign_edms_path(:event_id => @campaign.event_id, :campaign_id => @edm.campaign_id)
      end
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if params[:broadcast_date].present?
      @edm.edm_broadcast_time = @edm.set_time(params[:edm][:start_date_time],params[:edm][:start_time_hour],params[:edm][:start_time_minute],params[:edm][:start_time_am]) if (params[:edm][:edm_broadcast_value].present? and params[:edm][:edm_broadcast_value] == "scheduled")
      @edm.edm_broadcast_time = Time.now if (params[:edm][:edm_broadcast_value].present? and params[:edm][:edm_broadcast_value] == "now")
      @edm.edm_broadcast_value = params[:edm][:edm_broadcast_value]
      @edm.flag = "1"
      @edm.save
    else
      @edm.update_attributes(edm_params)
    end
      if @edm.errors.blank?
        if params[:commit].present? and params[:commit] == "NEXT"
          redirect_to edit_admin_event_campaign_edm_path(:event_id => @campaign.event_id, :campaign_id => @edm.campaign_id,:id => @edm.id,:next => params[:commit])
        else
          redirect_to admin_event_campaign_edms_path(:event_id => @campaign.event_id, :campaign_id => @edm.campaign_id)
        end
      else
        render :action => "edit"
      end
  end

  def show
  end

  def destroy
    if @edm.destroy
      redirect_to admin_event_campaign_edms_path(:event_id => @campaign.event_id, :campaign_id => @edm.campaign_id)
    end
  end

  protected

  def find_edms
    @campaign = @event.campaigns.find_by_id(params[:campaign_id])
    if @campaign.present?  
      @edms = @campaign.edms
      @edm = @edms.find_by_id(params[:id]) if params[:id].present? and @edms.present?
    end  
  end

  def edm_params
    params.require(:edm).permit!
  end
end
