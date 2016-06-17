class InviteeNotification < ActiveRecord::Base
  attr_accessor :platform
  belongs_to :notification

  validates :invitee_id, :notification_id, :event_id, presence: { :message => "This field is required." }
end
