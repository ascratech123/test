Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both thread web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.cache_store = :dalli_store, {:compress => true}

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_files = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = true

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Set to :debug to see everything in the log.
  config.log_level = :debug
#  config.log_level = :debug
  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  #config.action_controller.asset_host = "http://d1jg7fr0ifnr2k.cloudfront.net"

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # config.assets.precompile += %w( search.js )

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify#:log

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new
#  config.logger = Logger.new(STDOUT)
  config.logger = Logger.new('log/production.log')
  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
  config.action_mailer.default_url_options = { :host => 'platform.hobnobspace.com' }
# Settings specified here will take precedence over those in config/application.rb.


end


#Error Notifier
#Rails.application.config.middleware.use ExceptionNotification::Rack,
 # :ignore_exceptions => ['ActionView::TemplateError'] + ExceptionNotifier.ignored_exceptions,
# :email => {
#   :email_prefix => "Production Shobiz Error Notifier",
#   :sender_address => %w{info@hobnobspace.com},
#   :exception_recipients => %w{sushil@ascratech.in atul@ascratech.com gayatri@ascratech.com uday@ascratech.com chirag@ascratech.com}
# }


# Push Notification
Pusher_obj = Grocer.pusher(certificate: "#{Rails.root}/lib/shobiz_push.pem", passphrase: "shobiz", gateway: "gateway.sandbox.push.apple.com")
Gcm_obj = GCM.new('AIzaSyCurn11MPwTfQCF4RCnyOhbrDUJAqOLVWw')


APP_URL = "http://platform.hobnobspace.com"
SAPP_URL = "https://platform.hobnobspace.com"
S3_url = "http://s3-ap-southeast-1.amazonaws.com/shobiz-production"
S3_access_key = "AKIAI53KXYDOTGKHBAGQ"
S3_secret_access_key = "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"
S3_bucket = 'shobiz-production'

#d1zkvxtvahb2g5.cloudfront.net
S3_CREDENTIALS = {:access_key_id => S3_access_key,
                  :secret_access_key => S3_secret_access_key }
PAPERCLIP_SETTINGS =  { 
                        :url => ':s3_alias_url',
                        :s3_protocol => "http",
                        :s3_host_alias => 's3-ap-southeast-1.amazonaws.com/shobiz-production',
                        :storage => :s3,
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
                     :url => "#{S3_url}/imports/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

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

EXHIBITOR_IMAGE_PATH=   {:path => "exhibitor/image/:style/:id-:filename",
                     :url => "#{S3_url}/exhibitor/image/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

NOTIFICATION_IMAGE_PATH  = {:path => "notifications/image/:style/:id-:filename",
                     :url => "#{S3_url}/notifications/image/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)
                     
QNAWALL_LOGO_PATH  = {:path => "qna_walls/logo/:style/:id-:filename",
                     :url => "#{S3_url}/qna_walls/logo/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

CONVERSATIONWALL_LOGO_PATH  = {:path => "conversation_walls/logo/:style/:id-:filename",
                     :url => "#{S3_url}/conversation_walls/logo/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

POLLWALL_LOGO_PATH  = {:path => "poll_walls/logo/:style/:id-:filename",
                     :url => "#{S3_url}/poll_walls/logo/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)
                     
QUIZWALL_LOGO_PATH  = {:path => "quiz_walls/logo/:style/:id-:filename",
                     :url => "#{S3_url}/quiz_walls/logo/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)                                                                

QNAWALL_BG_IMAGE_PATH  = {:path => "qna_walls/background_image/:style/:id-:filename",
      :url => "#{S3_url}/qna_walls/background_image/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

CONVERSATIONWALL_BG_IMAGE_PATH  = {:path => "conversation_walls/background_image/:style/:id-:filename",
                     :url => "#{S3_url}/conversation_walls/background_image/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

POLLWALL_BG_IMAGE_PATH  = {:path => "poll_walls/background_image/:style/:id-:filename",
                     :url => "#{S3_url}/poll_walls/background_image/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)

QUIZWALL_BG_IMAGE_PATH  = {:path => "quiz_walls/background_image/:style/:id-:filename",
                     :url => "#{S3_url}/quiz_walls/background_image/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)
NOTIFICATION_IMAGE_FOR_SHOW_NOTIFICATION  = {:path => "notifications/image_for_show_notification/:style/:id-:filename",
                     :url => "#{S3_url}/notifications/image_for_show_notification/:style/:id-:filename"}.merge(PAPERCLIP_SETTINGS)
