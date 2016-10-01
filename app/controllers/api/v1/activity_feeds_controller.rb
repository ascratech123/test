class Api::V1::ActivityFeedsController < ApplicationController

  def index
    invitee = Invitee.find(session['invitee_id']) if session['invitee_id'].present?#Invitee.find_by_email("minu@test.com")
    event = Event.find(params[:event_id])#Event.find(165)
    @event_timezone_offset = event.timezone_offset
    @event_display_timezone = event.display_time_zone
    @background_color = event.theme.background_color
    @background_image = event.theme.event_background_image.url if event.theme.event_background_image_file_name.present?
    if invitee.present?
      # @analytics = invitee.analytics.where(:viewable_type => ["Conversation","Notification","InviteeNotification"], :action => ["comment", "conversation post", "like", "share", "notification"])
      conversation_ids = invitee.conversations.pluck(:id)
      viewable_types = ["Conversation","Notification","InviteeNotification"]
      actions = ["comment", "conversation post", "like", "share", "notification"]
      @analytics = Analytic.where("(invitee_id = ? and viewable_type IN (?) and action IN (?)) or (viewable_type = ? and viewable_id IN (?))", invitee.id,viewable_types,actions, "Conversation", ["like", "comment"]).where("viewable_id is not null").order("created_at desc")
      @analytics = @analytics.paginate(page: params[:page], per_page: 10)
      #@analytics = invitee.analytics.where(:action => "notification")
      #@analytics = invitee.analytics.where(:action => "notification").first
      #@analytics = [@analytics]
    end
    if false#event.present?
      @event_analytics = event.analytics.where(:viewable_type => ["Conversation","Notification"], :action => ["comment", "conversation post", "like", "share", "notification"]).where("viewable_id is not null").order("created_at desc")
      @event_analytics = @event_analytics.paginate(page: params[:page], per_page: 10)
    end
  end
end



