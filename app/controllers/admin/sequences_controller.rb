class Admin::SequencesController < ApplicationController
  layout 'admin'
  before_filter :check_user_role
  before_filter :authenticate_user, :authorize_event_role

  def update
    @event = Event.find_by_id(params[:event_id])
    feature_type = EventFeature.for_sequence_get_model_name[params[:feature_type]].constantize
    feature = feature_type.find_by_id(params[:id])
    @event.decide_seq_no(params[:seq_type],feature,feature_type)
    if feature_type == Winner
      winner = Winner.find_by_id(params[:id])
      @features = feature_type.where(:award_id => winner.award_id)
    elsif feature_type == Image
      @features = feature_type.where(:imageable_id => @event.id)
    elsif feature_type == Feedback
      @features = feature_type.where(:event_id => @event.id, :feedback_form_id => params["feedback_form_id"])
    else
      @features = feature_type.where(:event_id => @event.id)
    end
    @redirect_feature = params[:feature_type]
    instance_variable_set("@"+ params[:feature_type], @features)
    respond_to do |format|
      if @redirect_feature == "agenda_tracks"
        date = feature.agenda_date.strftime('%Y-%m-%d')
        path = "/admin/events/#{feature.event_id}/agendas"
        format.js{render :js => "window.location.href = '#{path}?d=#{date}'" }
      else  
        format.js{}
      end
      format.html{}
    end 
  end

  protected
    def check_user_role
      @event = Event.find_by_id(params[:event_id])
      if (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])) 
        redirect_to admin_dashboards_path
      end  
    end
end