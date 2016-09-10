Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.action_mailer.perform_deliveries = true
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.action_mailer.default_url_options = {host: 'localhost', port: 3000}
  config.action_mailer.delivery_method = :smtp
#   config.action_mailer.smtp_settings = {
#       :address              => "smtp.gmail.com",
#       :port                 => 587,
#       :domain               => "gmail.com",
#       :user_name            => "chiragarya123456@gmail.com",
#       #:user_name            => "mail@atulagrawal.in",
#       :password             => "123456qwerty,./",
#       #:password             => "syI;12#4",
#       :authentication       => :plain,
#       :enable_starttls_auto => true
# }
end



# Rails.application.config.middleware.use ExceptionNotification::Rack,
  
#   :webhook => {
#     :url => 'http://localhost:3000/clients',
#     :http_method => :get
#   }



#Error Notifier
# Rails.application.config.middleware.use ExceptionNotification::Rack,
#  # :ignore_exceptions => ['ActionView::TemplateError'] + ExceptionNotifier.ignored_exceptions,
#  :email => {
#    :email_prefix => "Development Shobiz Error Notifier",
#    :sender_address => %{"Error notifier" <error@ascratech.com>},
#    :exception_recipients => %w{shiv@ascratech.com}
#  }


# Push Notification
Pusher_obj = Grocer.pusher(certificate: "#{Rails.root}/lib/shobiz_push.pem", passphrase: "shobiz", gateway: "gateway.sandbox.push.apple.com")
Gcm_obj = GCM.new('AIzaSyCurn11MPwTfQCF4RCnyOhbrDUJAqOLVWw')


APP_URL = "http://localhost:3000"
SAPP_URL = "http://localhost:3000"
S3_url = "http://s3.amazonaws.com/shobiz-new-development"
S3_access_key = "AKIAIXEZXP4IENEMXA4Q"
S3_secret_access_key = "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"
S3_bucket = 'shobiz-new-development'


S3_CREDENTIALS = {:access_key_id => S3_access_key,
                  :secret_access_key => S3_secret_access_key }
PAPERCLIP_SETTINGS =  { :storage => :s3,
                        :s3_credentials => S3_CREDENTIALS,
                        :bucket => S3_bucket
                        }


ATTACH_FILE_PATH =   {:path => "my_travel/attachment1/:style/:id-:filename",
                     :url => "#{S3_url}/my_travel/attachment1/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)
ATTACH_FILE_2_PATH =   {:path => "my_travel/attachment2/:style/:id-:filename",
                     :url => "#{S3_url}/my_travel/attachment2/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)
ATTACH_FILE_3_PATH =   {:path => "my_travel/attachment3/:style/:id-:filename",
                     :url => "#{S3_url}/my_travel/attachment3/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)
ATTACH_FILE_4_PATH =   {:path => "my_travel/attachment4/:style/:id-:filename",
                     :url => "#{S3_url}/my_travel/attachment4/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)
ATTACH_FILE_5_PATH =   {:path => "my_travel/attachment5/:style/:id-:filename",
                     :url => "#{S3_url}/my_travel/attachment5/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

CKEDITOR_IMAGE_PATH =   {:path => "ckeditor/:style/:id-:filename",
                     :url => "#{S3_url}/ckeditor/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

SPEAKER_IMAGE_PATH =   {:path => "speaker/:style/:id-:filename",
                     :url => "#{S3_url}/speaker/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

SPONSOR_IMAGE_PATH =   {:path => "sponsor/:style/:id-:filename",
                     :url => "#{S3_url}/sponsor/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)                     

INVITEE_IMAGE_PATH =   {:path => "invitee/profile_pic/:style/:id-:filename",
                     :url => "#{S3_url}/invitee/profile_pic/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)                     

LICENSEE_IMAGE_PATH =   {:path => "licensee/:style/:id-:filename",
                     :url => "#{S3_url}/licensee/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

EXHIBITOR_IMAGE_PATH=   {:path => "exhibitor/image/:style/:id-:filename",
                     :url => "#{S3_url}/exhibitor/image/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

THEME_IMAGE_PATH =   {:path => "theme/:style/:id-:filename",
                     :url => "#{S3_url}/theme/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)           

HIGHLIGHT_IMAGE_PATH =   {:path => "highlight_image/:style/:id-:filename",
                     :url => "#{S3_url}/highlight_image/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

PICTURE_IMAGE_PATH =   {:path => "image/:style/:id-:filename",
                     :url => "#{S3_url}/image/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)  

EVENT_LOGO_PATH =   {:path => "event/logo/:style/:id-:filename",
                     :url => "#{S3_url}/event/logo/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

EVENT_INSIDE_LOGO_PATH =   {:path => "event/inside_logo/:style/:id-:filename",
                     :url => "#{S3_url}/event/inside_logo/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

                                        
CONVERSATION_IMAGE_PATH =   {:path => "conversation/:style/:id-:filename",
                     :url => "#{S3_url}/conversation/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

FEATURE_MENU_ICON_IMAGE_PATH =   {:path => "event_feature/menu_icon/:style:interpolate_time_stamp/:id-:filename",
                     :url => "#{S3_url}/event_feature/menu_icon/:style:interpolate_time_stamp/:id-:filename"}.merge(PAPERCLIP_SETTINGS)                      

EKIT_IMAGE_PATH =   {:path => "ekit/:id-:filename",
                     :url => "#{S3_url}/ekit/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

Emergency_Exit_IMAGE_PATH =   {:path => "emergency_exit/:id-:filename",
                     :url => "#{S3_url}/emergency_exit/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

Emergency_Exit_icon_IMAGE_PATH =   {:path => "emergency_exit_icon/:id-:filename",
                     :url => "#{S3_url}/emergency_exit_icon/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

FEATURE_MAIN_ICON_IMAGE_PATH =   {:path => "event_feature/main_icon/:style:main_icon_interpolate_time_stamp/:id-:filename",
                     :url => "#{S3_url}/event_feature/main_icon/:style:main_icon_interpolate_time_stamp/:id-:filename"}.merge(PAPERCLIP_SETTINGS)     

Mobile_Application_APP_ICON_PATH = {:path => "mobile_application/app_icon/:style/:id-:filename",
                     :url => "#{S3_url}/mobile_application/app_icon/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

Mobile_Application_SPLASH_SCREEN_PATH = {:path => "mobile_application/splash_screen/:style/:id-:filename",
                     :url => "#{S3_url}/mobile_application/splash_screen/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)
                     
Mobile_Application_LOGIN_BACKGROUND_PATH = {:path => "mobile_application/login_background/:style/:id-:filename",
                     :url => "#{S3_url}/mobile_application/login_background/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

Mobile_Application_LISTING_SCREEN_BACKGROUND_PATH = {:path => "mobile_application/listing_screen_background/:style/:id-:filename",
                     :url => "#{S3_url}/mobile_application/listing_screen_background/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

IMPORT_STORAGE = {:path => "imports/:id-:filename",
                     :url => "#{S3_url}/imports/:id-:basename.:extension"}.merge(PAPERCLIP_SETTINGS)
                     
PUSH_PEM_FILE_PATH =   {:path => "push_pem_files/pem_file/:id-:filename",
                     :url => "#{S3_url}/push_pem_files/pem_file/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

INVITEE_QR_CODE_PATH =   {:path => "invitees/qr_code/:style/:id-:filename",
                     :url => "#{S3_url}/invitees/qr_code/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

ANDROID_APP_ICON_PATH =   {:path => "app_infos/android_app_icons/:style/:id-:filename",
                     :url => "#{S3_url}/app_infos/android_app_icons/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

IOS_APP_ICON_PATH =   {:path => "app_infos/ios_app_icons/:style/:id-:filename",
                     :url => "#{S3_url}/app_infos/ios_app_icons/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

APP_SCREENSHOT_PATH =   {:path => "app_screenshot/screen/:style/:id-:filename",
                     :url => "#{S3_url}/app_screenshot/screen/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

NOTIFICATION_IMAGE_PATH  = {:path => "notifications/image/:style/:id-:filename",
                     :url => "#{S3_url}/notifications/image/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)
BADGE_IMAGE_PATH  = {:path => "badge_pdfs/image/:style/:id-:filename",
                     :url => "#{S3_url}/badge_pdfs/image/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)                     