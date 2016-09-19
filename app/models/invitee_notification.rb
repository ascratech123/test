class InviteeNotification < ActiveRecord::Base
  attr_accessor :platform
  belongs_to :notification

  validates :invitee_id, :notification_id, :event_id, presence: { :message => "This field is required." }
  after_save :update_last_updated_model
  
  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

end
