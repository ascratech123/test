class PushNotification < ActiveRecord::Base
  
  belongs_to :event

  validates :description,:event_id, presence: true

  after_create :push_notification

  def push_notification
    if self.push_datetime.blank?
      invitees = self.event.invitees
      self.update_column(:pushed, true)
      if invitees.present?
        invitees.each do |u|
          u.push_notifications(self.description, self.page, self.page_id)
        end
      end
    end
  end

  def self.push_notification_time_basis
    Rails.logger.info("***************PushNotification *********#{Time.now}*********************")
    puts "*************PushNotification********#{Time.now}**********************"
    push_notifications = PushNotification.where(:pushed => false, :push_datetime => Time.now..Time.now + 30.minutes)
    if push_notifications.present?
      push_notifications.each do |push_notification|
        invitees = push_notification.event.invitees
        push_notification.update_column(:pushed, true)
        if invitees.present?
          invitees.each do |u|
            u.push_notifications(push_notification.description, push_notification.page, push_notification.page_id)
          end
        end
      end
    end
  end

end
