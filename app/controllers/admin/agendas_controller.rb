class Admin::AgendasController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :find_ratings, :only => [:index, :new]

  def index
    @agenda_group_by_start_agenda_time = @agendas.group("date(start_agenda_time)")
    @agenda_having_no_date = @agendas.where("start_agenda_time is null")
    @page = params[:controller].split("/").second
    @event_feature = @event.event_features.where(:name => @page)
    respond_to do |format|
      format.html  
      format.xls do
        only_columns = []
        method_allowed = [:Timestamp, :email_id, :first_name, :last_name, :session_name, :speaker_name,:star_rating,:user_comment]
        send_data @feedbacks.to_xls(:only => only_columns, :methods => method_allowed)
      end
    end
  end

  def new
    agenda_data = Agenda.find(params[:id]) rescue Agenda.new
    @agenda = @event.agendas.build(agenda_data.attributes.except('id', 'created_at', 'updated_at', 'start_agenda_time', 'end_agenda_time'))
    @spearkers = @event.speakers
    @import = Import.new if params[:import].present?
  end
  
  def create
    # params[:agenda][:speaker_id] = nil if params[:agenda][:speaker_id] == "add_speaker"
    @agenda = @event.agendas.build(agenda_params)
    # @agenda.agenda_type = params[:agenda][:new_category] if params[:agenda][:agenda_type].present? and params[:agenda][:agenda_type] == 'New Category' and params[:agenda][:new_category].present?
#    if params[:agenda][:agenda_track_id].present? and params[:agenda][:agenda_track_id] == '0'
      @agenda_track_new = AgendaTrack.set_agenda_track(params)
      @agenda.agenda_track_id = @agenda_track_new.id if @agenda_track_new.present?
#    end
    if @agenda.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      else
        redirect_to admin_event_agendas_path(:event_id => @agenda.event_id)
      end
    else
      render :action => 'new'
    end
  end


  def edit
  end

  def update
    # params[:agenda][:speaker_id] = nil if params[:agenda][:speaker_id].to_i == 0
    @agenda.update_column(:end_agenda_time, nil) if params[:agenda][:end_time_hour].blank? and params[:agenda][:end_time_minute].blank? and params[:agenda][:end_time_am].blank?
      @agenda_track_new = AgendaTrack.set_agenda_track(params)
      @agenda.agenda_track_id = @agenda_track_new.id if @agenda_track_new.present?
    if @agenda.update_attributes(agenda_params)
      redirect_to admin_event_agendas_path(:event_id => @agenda.event_id)
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @agenda.destroy
      redirect_to admin_event_agendas_path(:event_id => @agenda.event_id)
    end
  end

  protected

  def find_ratings
    @feedbacks = Rating.where(:ratable_type => 'Agenda', :ratable_id => @agendas.pluck(:id)) if @agendas.present?
  end

  def agenda_params
    if params[:agenda][:start_agenda_time].present?
      params["agenda"]["start_agenda_time"].to_time
    end
    params.require(:agenda).permit!
  end
end
