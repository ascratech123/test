require 'rubygems'
require 'aws-sdk'
require 'fcm'
module PushNotification
  
  
  def self.push_notification(notification, objekts, mobile_application_id)
    if notification.present? and objekts.present?
      notification.update_column(:pushed, true)
      # notification.create_notification_in_analytic
      notification.update_column(:push_datetime,Time.now + notification.event_timezone_offset.to_i.seconds)
      if objekts.present?
        arr = objekts.map{|invitee| {invitee_id:invitee.id,notification_id:notification.id,event_id:notification.event_id}}
        InviteeNotification.create(arr)
        push_pem_file = PushPemFile.where(:mobile_application_id => mobile_application_id).last
        event = notification.event
        title = push_pem_file.title.present? ? push_pem_file.title : event.event_name
        ios_obj = Grocer.pusher("certificate" => push_pem_file.pem_file.url.split('?').first, "passphrase" => push_pem_file.pass_phrase, "gateway" => push_pem_file.push_url)
        objekts.each do |objekt|
          PushNotification.push_to_user(objekt, notification, mobile_application_id, push_pem_file, ios_obj, title)
        end
      end
    end
  end


  def self.push_to_user(objekt, notification, mobile_application_id, push_pem_file, ios_obj, title)
    b_count = objekt.get_badge_count
    page_id = notification.page_id rescue 1
    push_page = notification.push_page rescue 'home'
    ios_devices = objekt.devices.where(:platform => 'ios', :mobile_application_id => mobile_application_id).where.not(:enabled => "false")
    android_devices = objekt.devices.where(:platform => 'android', :mobile_application_id => mobile_application_id).where.not(:enabled => "false")
    if ios_devices.present?
      ios_devices.each do |device|
        puts "******************************#{device.token}**************#{device.email}**************************************"
        Rails.logger.info("******************************#{device.token}****************#{device.email}************************************")
        PushNotification.push_to_ios(device.token, notification, push_pem_file, ios_obj, title, b_count)
      end
    end
    if android_devices.present?
      PushNotification.push_to_android(android_devices.pluck(:token), notification, push_pem_file, title, b_count)
    end
  end

  def self.push_to_ios(token, notification, push_pem_file, ios_obj, title, b_count)
    puts "******************************#{token}****************************************************"
    Rails.logger.info("******************************#{token}****************************************************")
    msg = notification.description
    push_page = notification.push_page
    type = notification.group_ids.present? ? notification.group_ids : 'All'
    page_id = 0
    time = notification.push_datetime
    ios_obj = Grocer.pusher("certificate" => push_pem_file.pem_file.url.split('?').first, "passphrase" => push_pem_file.pass_phrase, "gateway" => push_pem_file.push_url)
    notification = Grocer::Notification.new("device_token" => token, "alert"=>{"title"=> title, "body"=> msg, "action"=> "Read"}, 'content_available' => true, "badge" => b_count, "sound" => "siren.aiff", "custom" => {"push_page" => push_page, "id" => page_id, 'event_id' => notification.event_id, 'image_url' => notification.image.url, 'type' => type, 'created_at' => time, 'notification_id' => notification.id, :formatted_push_datetime_with_event_timezone => notification.formatted_push_datetime_with_event_timezone})
    response = ios_obj.push(notification)
    Rails.logger.info("******************************#{response}****************************************************")
  end

  def self.push_to_android(tokens, notification, push_pem_file, title, b_count=1)
    mobile_application = notification.event.mobile_application
    if mobile_application.present? and mobile_application.android_push_service == "fcm"
      fcm_obj = FCM.new(push_pem_file.android_push_key)  
      msg = notification.description
      push_page = notification.push_page
      type = notification.group_ids.present? ? notification.group_ids : 'All'
      page_id = 0
      time = notification.push_datetime
      options = {'data' => {'message' => msg, 'page' => push_page, 'page_id' => page_id, 'title' => title, 'event_id' => notification.event_id, 'image_url' => notification.image.url, 'type' => type, 'created_at' => time, 'notification_id' => notification.id, :formatted_push_datetime_with_event_timezone => notification.formatted_push_datetime_with_event_timezone, 'push_type' => "fcm"}}
      response = fcm_obj.send(tokens, options)
      puts "******************************#{response}*************response of fcm***************************************"
      Rails.logger.info("******************************#{response}***************response of fcm*************************************")
    else  
      gcm_obj = GCM.new(push_pem_file.android_push_key)
      msg = notification.description
      push_page = notification.push_page
      type = notification.group_ids.present? ? notification.group_ids : 'All'
      page_id = 0
      time = notification.push_datetime
      options = {'data' => {'message' => msg, 'page' => push_page, 'page_id' => page_id, 'title' => title, 'event_id' => notification.event_id, 'image_url' => notification.image.url, 'type' => type, 'created_at' => time, 'notification_id' => notification.id, :formatted_push_datetime_with_event_timezone => notification.formatted_push_datetime_with_event_timezone}}
      response = gcm_obj.send(tokens, options)
      puts "******************************#{response}*************response of gcm***************************************"
      Rails.logger.info("******************************#{response}***************response of gcm*************************************")
    end  
  end

end
