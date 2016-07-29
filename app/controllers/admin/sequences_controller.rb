class Admin::SequencesController < ApplicationController
  layout 'admin'

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
    else
      @features = feature_type.where(:event_id => @event.id)
    end
    @redirect_feature = params[:feature_type]
    instance_variable_set("@"+ params[:feature_type], @features)
    respond_to do |format|
      format.js{}
      # format.js{render :js => "window.location.href = '#{request.referer}'" }
      format.html{}
    end 
  end
end