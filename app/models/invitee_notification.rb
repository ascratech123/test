class InviteeNotification < ActiveRecord::Base
	belongs_to :notification

  validates :invitee_id, :notification_id, :event_id, presence: { :message => "This field is required." }
end
