class Notification < ActiveRecord::Base
  require 'rubygems'
  require 'aws-sdk'
  require 'push_notification'
  ACTION_TO_PAGE_HSH = {'Group Notification' => 'Group','Agenda Rating' => 'Agenda', 'Agenda Favorite' => 'Agenda', 'Speaker Rating' => 'Speaker', 'Speaker Favorite' => 'Speaker', 'Invitee Favorite​' => 'Invitee', 'Sponsors Favorite' => 'Sponsor', 'Sponsors' => 'Sponsor', 'Exhibitors Favorite​​' => 'Exhibitor', 'Polls Taken' => 'Poll', 'Feedback Submitted' => 'Feedback', 'Quiz Answered' => 'Quiz', 'Question Asked' => 'Q&A', 'QR code scanned' => 'QR code', 'Event Highlight' => 'Event Highlight', 'Event Listing' => 'Event Listing', 'Quiz' => 'Quiz', 'Q&A' => 'Q&A', 'Speaker' => 'Speaker', 'Invitee' => 'Invitee', 'Profile' => 'Profile', 'Feedback' => 'Feedback', 'Agenda' => 'Agenda', 'Quiz' => 'Quiz', 'Poll' => 'Poll', 'Leaderboard' => 'Leaderboard', 'FAQ' => 'FAQ', 'About' => 'About', 'Conversation' => 'Conversation', 'E-Kit' => 'E-Kit', 'Award' => 'Award', 'Contact' => 'Contact', 'Sponsor' => 'Sponsor', 'Gallery' => 'Gallery', 'Emergency Exit' => 'Emergency Exit', 'Note' => 'Note', 'Venue' => 'Venue', 'Custom Page1' => 'Custom Page1', 'Custom Page2' => 'Custom Page2', 'Custom Page3' => 'Custom Page3', 'Custom Page4' => 'Custom Page4', 'Custom Page5' => 'Custom Page5', 'My Travel' => 'My Travel', 'Exhibitor' => 'Exhibitor', 'My Favorite' => 'My Favorite', 'QR code' => 'QR code', 'Home Page' => 'home'}
  
  attr_accessor :push_time_hour, :push_time_minute ,:push_time_am, :push_timing, :n_user
  serialize :group_ids, Array

  has_attached_file :image, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(NOTIFICATION_IMAGE_PATH)

  
  validates_attachment_content_type :image, :content_type => ["image/png", "image/JPEG", "image/jpeg", "image/jpg", "image/jpeg"]
  validates_attachment_size :image, :less_than => 100.kilobytes
  # validate :image_dimensions

  belongs_to :resourceable, polymorphic: true
  belongs_to :event
  has_many :invitee_notifications, :dependent => :destroy
  validates :description,:event_id, presence: { :message => "This field is required." }
  validates_length_of :description, :maximum => 200, :message => "Text must be less than 200 character"
  validates :group_ids, presence:{ :message => "This field is required." }, if: Proc.new { |n| n.notification_type == 'group' }
  validates :push_datetime, presence:{ :message => "This field is required." }, if: Proc.new { |n| n.push_timing == 'later' }
  validates :notification_type, presence: true
  after_create :set_event_timezone
  before_save :update_details
  after_save :push_notification

  default_scope { order('created_at desc') }

  def update_details
    self.push_page = Notification::ACTION_TO_PAGE_HSH[self.action]
  end

  def push_notification
    if self.push_datetime.blank?
      self.update_column(:push_datetime, Time.now)
      # if self.group_ids.present?
      #   groups = InviteeGroup.where("id IN(?)", self.group_ids)
      #   invitee_ids = []
      #   groups.each do |group|
      #     invitee_ids = invitee_ids + group.get_invitee_ids
      #   end  
      #   invitee_ids = invitee_ids.uniq rescue []
      #   invitees = Invitee.where("id IN(?)", invitee_ids)
      #   mobile_application = self.event.mobile_application
      #   push_pem_file = mobile_application.push_pem_file if mobile_application.present?
      # # invitees = Notification.get_action_based_invitees(invitees, self.action)
      #   if mobile_application.present? and mobile_application.push_pem_file.present?
      #     PushNotification.push_notification(self, invitees, mobile_application.id)
      #   end
      # else
      #   invitees = self.event.invitees
      #   objects = event.invitees
      #   self.send_to_all
      # end
    end
  end

  def self.push_notification_time_basis
    puts "*************PushNotification********#{Time.now}**********************"
    # notifications = Notification.where(:pushed => false, :push_datetime => Time.now..Time.now + 30.minutes)
    notifications = Notification.where("pushed = ? and push_datetime < ? and push_datetime > ?", false, (Time.now).utc.to_formatted_s(:db), (Time.now - 10.minutes).utc.to_formatted_s(:db))
    if notifications.present?
      notifications.each do |notification|
        event = notification.event
        if event.mobile_application_id.present?
          if notification.group_ids.present?
            groups = InviteeGroup.where("id IN(?)", notification.group_ids)
            invitee_ids = []
            groups.each do |group|
              invitee_ids = invitee_ids + group.get_invitee_ids
            end  
            invitee_ids = invitee_ids.uniq rescue []
            objects = Invitee.where("id IN(?)", invitee_ids)
            PushNotification.push_notification(notification, objects, event.mobile_application_id) if objects.present?
          else
            objects = event.invitees
            notification.send_to_all
          end
        end
      end
    end
  end

  def send_to_all
    mobile_application_id = self.event.mobile_application_id rescue nil
    self.update_column(:pushed, true)
    self.update_column(:push_datetime, Time.now)
    invitees = Invitee.where(:event_id => self.event_id)
    arr = invitees.map{|invitee| {invitee_id:invitee.id,notification_id:self.id,event_id:self.event_id}}
    InviteeNotification.create(arr)
    if mobile_application_id.present?
      push_pem_file = PushPemFile.where(:mobile_application_id => mobile_application_id).last
      ios_devices = Device.where(:platform => 'ios', :mobile_application_id => mobile_application_id, :invitee_id => invitees.pluck(:id))
      android_devices = Device.where(:platform => 'android', :mobile_application_id => mobile_application_id, :invitee_id => invitees.pluck(:id))
      event = self.event
      title = push_pem_file.present? and push_pem_file.title.present? ? push_pem_file.title : event.event_name
      if ios_devices.present? and push_pem_file.present?
        msg = self.description
        push_page = self.push_page
        type = self.group_ids.present? ? self.group_ids : 'All'
        page_id = 0
        time = self.push_datetime
        b_count = 1
        ios_devices.each do |device|
          ios_obj = Grocer.pusher("certificate" => push_pem_file.pem_file.url.split('?').first, "passphrase" => push_pem_file.pass_phrase, "gateway" => push_pem_file.push_url)
          Rails.logger.info("***********#{device.token}***************#{device.email}********************")
          self.push_to_ios(device.token, self, push_pem_file, ios_obj, b_count, msg, push_page, type, time, title)
        end
      end
      PushNotification.push_to_android(android_devices.pluck(:token), self, push_pem_file, title, 1) if android_devices.present?
    end
  end

  def push_to_ios(token, notification, push_pem_file, ios_obj, b_count, msg, push_page, type, time, title)
    notification = Grocer::Notification.new("device_token" => token, "alert"=>{"title"=> title, "body"=> msg, "action"=> "Read"}, 'content_available' => true, "badge" => b_count, "sound" => "siren.aiff", "custom" => {"push_page" => push_page, "id" => '1', 'event_id' => notification.event_id, 'image_url' => notification.image.url, 'type' => type, 'created_at' => time, 'notification_id' => notification.id})
    response = ios_obj.push(notification)
    Rails.logger.info("******************************#{response}****************************************************")
  end

  def self.get_action_based_invitees(invitees, notification_type)
    case notification_type
    when 'Agenda Rating'
      invitee_ids = Analytic.where(:action => 'rated', :viewable_type => 'Agenda').pluck(:invitee_id).uniq
      invitees = invitees.where(:id => invitee_ids)
    when 'Speaker Rating'
      invitee_ids = Analytic.where(:action => 'rated', :viewable_type => 'Speaker').pluck(:invitee_id).uniq
      invitees = invitees.where(:id => invitee_ids)
    when 'Agenda Favorite​'
      invitee_ids = Analytic.where(:action => 'favorite', :viewable_type => 'Sessions').pluck(:invitee_id).uniq
      invitees = invitees.where(:id => invitee_ids)
    when 'Speaker Favorite​'
      invitee_ids = Analytic.where(:action => 'favorite', :viewable_type => 'Speaker').pluck(:invitee_id).uniq
      invitees = invitees.where(:id => invitee_ids)
    when 'Invitee Favorite​'
      invitee_ids = Analytic.where(:action => 'favorite', :viewable_type => 'Invitee').pluck(:invitee_id).uniq
      invitees = invitees.where(:id => invitee_ids)
    when 'Sponsors Favorite​'
      invitee_ids = Analytic.where(:action => 'favorite', :viewable_type => 'Sponsor').pluck(:invitee_id).uniq
      invitees = invitees.where(:id => invitee_ids)
    when 'Exhibitors Favorite​'
      invitee_ids = Analytic.where(:action => 'favorite', :viewable_type => 'Exhibitor').pluck(:invitee_id).uniq
      invitees = invitees.where(:id => invitee_ids)
    when 'Polls Taken'
      invitee_ids = Analytic.where(:action => 'poll answered', :viewable_type => 'Poll').pluck(:invitee_id).uniq
      invitees = invitees.where(:id => invitee_ids)
    when 'Feedback Submitted'
      invitee_ids = Analytic.where(:action => 'feedback given', :viewable_type => 'Feedback').pluck(:invitee_id).uniq
      invitees = invitees.where(:id => invitee_ids)
    when 'Quiz Answered'
      invitee_ids = Analytic.where(:action => 'played', :viewable_type => 'Quiz').pluck(:invitee_id).uniq
      invitees = invitees.where(:id => invitee_ids)
    when 'Question Asked'
      invitee_ids = Analytic.where(:action => 'question asked', :viewable_type => 'Q&A').pluck(:invitee_id).uniq
      invitees = invitees.where(:id => invitee_ids)
    when 'QR code scanned'
      invitee_ids = Analytic.where(:action => 'qr code scan', :viewable_type => 'Invitee').pluck(:invitee_id).uniq
      invitees = invitees.where(:id => invitee_ids)
    end
    invitees
  end

  def set_time(push_datetime, push_time_hour, push_time_minute, push_time_am)
    if push_datetime.present?
      time = "#{push_datetime} #{push_time_hour.gsub(':', "") rescue nil}:#{push_time_minute.gsub(':', "") rescue nil}:#{0} #{push_time_am}"
      time = time.to_datetime rescue nil
      self.push_datetime = time
    end
  end

  def get_group_ids
    self.group_ids.join(",") rescue []
  end

  def get_invitee_ids
    if self.group_ids.present?
      groups = InviteeGroup.where(:id => self.group_ids)
      invitee_ids = []
      groups.map{|g| Invitee.where(:id => invitee_ids += g.invitee_ids).pluck(:id)}
      invitee_ids = invitee_ids.uniq.join(',')
    else
      invitee_ids = 'All'
    end
    invitee_ids
  end
  # def get_notification_dropdown_list
  #   grouped_options []
  #   [['Action based',[['Agenda Rating', 'agenda'], 'Agenda Favorite', 'Speaker Rating', 'Speaker Favorite', 'Invitee Favorite', 'Sponsors Favorite', 'Exhibitors Favorite']],['Logic based',['Polls Taken', 'Feedback Submitted', 'Quiz Answered', 'Question Asked', 'QR code scanned']],['Destination based',['Highlight', 'Event Listing', 'Quiz', 'Q&N', 'Speaker', 'Invitee', 'Profile ', 'Feedback', 'Agenda', 'Quiz', 'Leaderboard', 'FAQ', 'About', 'Conversation', 'E-Kit', 'Award', 'Contact', 'Sponsor', 'Gallery', 'Emergency Exit', 'Note', 'Venue', 'Custum Page1', 'Custum Page2', 'Custum Page3', 'Custom Page4', 'Custom Page5']]]
    
  #   event_features.each do |feature|

  # end

  def formatted_push_datetime_with_event_timezone
    self.push_datetime.in_event_timezone(self.event_timezone).strftime("%b %d at %I:%M %p")
  end

  def set_event_timezone
    self.update_column(:event_timezone, self.event.timezone)
  end

end