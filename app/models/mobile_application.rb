class MobileApplication < ActiveRecord::Base
  include AASM
  require 'review_status'
  resourcify
  serialize :preferences
  USER_ENGAGEMENT = ['Conversation', 'Favorite', 'Rating', 'Q&A', 'Poll', 'Feedback', 'E-Kit', 'QR code scan', 'Quiz']
  USER_ENGAGEMENT_FEATURE = {"abouts" => 'About', "awards" => 'Award', "speakers" => 'Speaker', "polls" => 'Poll', "invitees" => 'Invitee', "faqs" => 'FAQ', "conversations" => 'Conversation', "e_kits" => 'E-Kit', "qnas" => 'Q&A', "agendas" => 'Agenda', "contacts" => 'Contact', "galleries" => 'Gallery', "feedbacks" => 'Feedback', "emergency_exits" => 'Emergency Exit', "event_highlights" => 'Event Highlight', "notes" => 'Note', "sponsors" => 'Sponsor', "my_profile" => 'My Profile', "qr_code" => 'QR Code Scan'}

  CARD_IMAGES = {"notifications" => "notification.png", "Notifications sent" => "notification.png", "highlights"=> "event_highlights.png", 'event highlights' => "event_highlights.png", "gallery listings" => 'galler_1y.png', "highlight_images" => "gallery.png","contacts" => "contact_us.png","emergency_exits" => "emergency_exit.png", "About" => "about.png","abouts" => "about.png", 'Speakers' => "speakers.png", 'Speaker' => "speakers.png", "speakers" => "speakers.png", 'Sessions' => 'agenda.png', 'sessions' => 'agenda.png', "Agenda" => "agenda.png", "agendas" => "agenda.png", "invitees" => "invitees.png", "awards" => "awards_2.png", "polls" => "polls_1.png", "Conversation" => "conversations.png", "Conversations" => "conversations.png", "conversations" => "conversations.png", "faqs" => "faq.png", "e_kits" => "e-kit.png", "Questions Asked" => "Q&A.png", "feedbacks" => "feedback.png", "images" => "galler_1y.png", "mobile_applications" => "mobile-app.png", "winners" => "winner.png", "panels" => "panel_1.png", "dashboards" => "dashboard.png", "events" => "event.png", "clients" => "client.png", "users" => "user_3.png", "licensees" => "licensee.png", "imports" => "invitees.png", "push_pem_files" => "user-permission.png", "store_infos" => "mobile-app.png", "menus" => "user-permission.png","sponsor" => "sponsor.png", 'sponsors' => "sponsor.png", "invitee_structures" => "database.png","registrations"=>"registration.png", "my profiles" => "my_profile.png", "quizzes" =>"polls.png", 'Poll' => 'polls_1.png', 'polls' => 'polls_1.png', 'Exhibitors listing' => 'Exhibitor-breadcumb.png', "exhibitors" => "Exhibitor-breadcumb.png", 'qr codes' => 'qr_code.png', 'QR Code scans' => 'qr_code.png', "e-Kit Document Views" => 'e-kit.png', "e-kits" => 'e-kit.png', 'venues' => 'emergency_exit.png', 'notes' => 'note.png', 'emergency exits' => 'emergency_exit.png', 'edit profiles' => 'my_profile.png', 'q&as' => 'Q&A.png', 'galleries' => 'galler_1y.png', "Notifications sent" => "notification.png", 'Q&As' => 'Q&A.png', "E-Kits" => 'e-kit.png', 'Page views' => 'page_view_icon.png', 'Favorites' => "myfavourite.png", 'Session Ratings' => 'feedback.png', 'Speaker Ratings' => 'feedback.png', 'Q&As' => "Q&A-breadcumb.png", 'Polls taken' => "polls_1.png", 'Feedback Submitted' => "feedback-breadcumb.png", 'Quiz' => "polls_breadcumb.png", 'Quiz answered' => 'polls_breadcumb.png', "Ios active users" => "invitees.png", "Ios unique users" => "invitees.png", "Total active users" => "invitees.png", "Total unique users" => "invitees.png", 'my favorites' => 'myfavourite.png'}
  BREADCRUM_IMAGES = {"themes" => "themes_breadcumb.png","event_features"=>"feature-breadcumb.png","notifications" => "notification-breadcumb.png", "event_highlights"=>"event_highlights-breadcumb.png","highlight_images"=>"gallery.png","contacts"=>"contact_us-breadcumb.png","emergency_exits"=>"venue-breadcumb.png", "abouts" => "about-breadcumb.png", "speakers" => "speakers-breadcumb.png", "agendas" => "agenda-breadcumb.png", "invitees" => "invitees-breadcumb.png", "awards" => "awards_2-breadcumb.png", "polls" => "polls_1-breadcumb.png", "conversations" => "conversations_breadcumb.png", "faqs" => "faq-breadcumb.png", "e_kits" => "e-kit-breadcumb.png", "qnas" => "Q&A-breadcumb.png", "feedbacks" => "feedback-breadcumb.png", "images" => "galler_1y-breadcumb.png", "mobile_applications" => "mobile-app-breadcumb.png", "winners" => "winner-breadcumb.png", "panels" => "panel_1-breadcumb.png", "dashboards" => "dashboard.png", "events" => "event-breadcumb.png", "clients" => "client-breadcumb.png", "users" => "user_3-breadcumb.png", "licensees" => "licensee_breadcumb.png", "imports" => "invitees-breadcumb.png", "push_pem_files" => "user-permission_breadcumb.png", "store_infos" => "mobile-app-breadcumb.png", "menus" => "menu-breadcumb.png","sponsors" => "sponsor-breadcumb.png", "invitee_structures" => "database-breadcumb.png","registrations"=>"registration-breadcumb.png", "profiles" => "my_profile_breadcumb.png", "quizzes" =>"polls_breadcumb.png", "exhibitors" => "Exhibitor-breadcumb.png", "manage_mobile_apps" => "mobile-app-breadcumb.png", "custom_page1s" => "custom.png", "custom_page2s" => "custom.png", "custom_page3s" => "custom.png", "custom_page4s" => "custom.png", "custom_page5s" => "custom.png","registration_settings" => "registration-setting.png","telecallers" => "telecaller.png","invitee_datas" => "telecaller.png","groupings" => "database.png","user_registrations"=>"registration.png","my_travels" => "travel.png","smtp_settings"=>"smtp_setting.png","manage_invitee_fields"=>"manage_invitee.png", "qna_walls"=>"settings.png", "conversation_walls" =>"settings.png", "quiz_walls"=>"settings.png","poll_walls"=>"settings.png", 'activity_feeds' => 'activity_feed.png' }
  # attr_accessor :template_id
  
  belongs_to :client
  has_one :push_pem_file, :dependent => :destroy
  has_one :store_info
  has_many :events
  accepts_nested_attributes_for :events

  after_save :update_client_id
  after_create :set_preview_submitted_code
  after_save :update_social_media_status

  has_attached_file :app_icon, {:styles => {:large => "90x90>",
                                         :small => "60x60>", 
                                         :thumb => "54x54>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(Mobile_Application_APP_ICON_PATH)
  
  has_attached_file :splash_screen, {:styles => {:large => "1024x2208>",
                                         :small => "600x600>", 
                                         :thumb => "200x200>"},
                             :convert_options => {:large => "-strip -quality 80", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(Mobile_Application_SPLASH_SCREEN_PATH)

  has_attached_file :login_background, {:styles => {:large => "1024x2208>",
                                         :small => "600x600>", 
                                         :thumb => "200x200>"},
                             :convert_options => {:large => "-strip -quality 80", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(Mobile_Application_LOGIN_BACKGROUND_PATH)

  has_attached_file :listing_screen_background, {:styles => {:large => "1024x2208>",
                                         :small => "600x600>", 
                                         :thumb => "200x200>"},
                             :convert_options => {:large => "-strip -quality 80", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(Mobile_Application_LISTING_SCREEN_BACKGROUND_PATH)

  validates_attachment_content_type :app_icon,:content_type => ["image/png"],:message => "please select valid format."
  validates_attachment_content_type :splash_screen, :content_type => ["image/png"],:message => "please select valid format."
  validates :name, :application_type, :listing_screen_text_color, presence: { :message => "This field is required." }
  validate :listing_screen_text_color_presentce
  validates :name, uniqueness: {scope: :client_id}
  
  validate :image_dimensions_for_app_icon, :if => Proc.new{|p| p.app_icon_file_name_changed? and p.app_icon_file_name.present?}
  validate :image_dimensions_for_splash_screen, :if => Proc.new{|p| p.splash_screen_file_name_changed? and p.splash_screen_file_name.present? }
  validate :image_dimensions_for_login_background, :if => Proc.new{|p| p.login_background_file_name_changed? and p.login_background_file_name.present? }
  validate :image_dimensions_for_screen_background, :if => Proc.new{|p| p.listing_screen_background_file_name_changed? and p.listing_screen_background_file_name.present? }
  
  after_save :update_last_updated_model
  
  default_scope { order('created_at desc') }

  aasm :column => :status do  # defaults to aasm_state
    state :draft, :initial => true
    state :submitted

    event :submit_to_store do
      transitions :from => [:draft], :to => [:submitted]
    end 
    event :remove_from_store do
      transitions :from => [:submitted], :to => [:draft]
    end 
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def update_social_media_status
    if self.social_media_status.blank?
      self.update_column(:social_media_status, 'deactive')
    end
  end

  def listing_screen_text_color_presentce
    if self.application_type != "single event" 
      errors.add(:listing_screen_text_color , "This field is required.") if self.listing_screen_text_color.blank?
    else
      self.errors.delete(:listing_screen_text_color)
    end
  end
  def mobile_app_status(status)
    if status== "submit_to_store"
      self.submit_to_store!
    end
  end

  def splash_screen_url(style=:large)
    style.present? ? self.splash_screen.url(style) : self.splash_screen.url
  end

  def login_background_url(style=:large)
    style.present? ? self.login_background.url(style) : self.login_background.url
  end

  def listing_screen_background_url(style=:large)
    style.present? ? self.listing_screen_background.url(style) : self.listing_screen_background.url
  end

  def app_icon_url(style=:large)
    style.present? ? self.app_icon.url(style) : self.app_icon.url
  end

  def update_client_id
    if self.events.present?
      self.update_column(:client_id, self.events.first.client_id)
    end
  end

  def self.search(params, mobileapplications)
    keyword = params[:search][:keyword]
    mobileapplications = mobileapplications.where("name like (?)", "%#{keyword}%")if keyword.present?
    mobileapplications 
  end

  def set_preview_submitted_code
    new_preview_code = ""
    loop do
      new_preview_code = (0...5).map { ('A'..'M').to_a[rand(13)] }.join
      new_preview_code = "P" + new_preview_code
      break new_preview_code unless MobileApplication.pluck(:preview_code).include?(new_preview_code)
    end
    self.update_column(:preview_code, new_preview_code)

    new_submitted_code = ""
    loop do
      new_submitted_code = (0...5).map { ('N'..'Z').to_a[rand(13)] }.join
      new_submitted_code = "S" + new_submitted_code
      break new_submitted_code unless MobileApplication.pluck(:submitted_code).include?(new_submitted_code)
    end
    self.update_column(:submitted_code, new_submitted_code)
  end

  def review_status
    features_arr = ['name', 'application_type', 'template_id', 'app_icon_file_name', 'splash_screen_file_name']
    extra_count = 0
    if self.login_at == 'Yes'
      features_arr += ['login_background_file_name']
    else
      extra_count += 1 if self.login_at.present?
    end
    features_arr += ['listing_screen_background_file_name', 'listing_screen_text_color'] if self.application_type == 'multi event'
    ReviewStatus.review(self, features_arr, extra_count, (features_arr.length + extra_count))
  end

  def old_review_status
    features_arr = {'name' => '', 'application_type' => '', 'template_id' => '', 'app_icon_file_name' => '', 'login_at' => ''}
    features_arr.merge!('listing_screen_background_file_name' => '') if self.application_type == 'multi event'
    features_arr.merge!('login_background_file_name' => '') if self.login_at == 'Yes'
    ReviewStatus.review(self, features_arr)
  end

  # def new_review_status(objekt, features_arr)
  #   #features_arr = {'name' => '', 'application_type@@multi event' => ['listing_screen_background'], 'template_id' => '', 'app_icon' => '', 'login_at@@yes' => ['login_background']}
  #   count, total = 0, features_arr.length
  #   features_arr.keys.each do |feature|
  #     field_name, value = feature.split('@@')
  #     if objekt.attribute_present? (field_name) and (value.blank? or (value.present? and objekt.attributes[field_name] == value))
  #       count, total = count+1, (total+features_arr[feature].length)
  #       if features_arr[feature].present?
  #         features_arr[feature].each do |sub_feature|
  #           sub_field_name, sub_value = sub_feature.split('@@')  
  #           count += 1 if objekt.attribute_present? (sub_field_name) and (sub_value.blank? or (sub_value.present? and objekt.attributes[sub_field_name] == sub_value))
  #         end
  #       end
  #     end
  #   end
  #   ((count/total.to_f) * 100).to_i
  # end

  def image_dimensions_for_app_icon
    mobile_dimension_height_app_icon, mobile_dimension_width_app_icon  = 180.0, 180.0
    dimensions_app_icon = Paperclip::Geometry.from_file(app_icon.queued_for_write[:original].path)
    errors.add(:app_icon, "Image size should be 180x180px only") if (dimensions_app_icon.width != mobile_dimension_width_app_icon or dimensions_app_icon.height != mobile_dimension_height_app_icon)
  end
  
  def image_dimensions_for_splash_screen
    mobile_dimension_height_splash_screen, mobile_dimension_width_splash_screen  = 1600.0, 960.0
    dimensions_splash_screen = Paperclip::Geometry.from_file(splash_screen.queued_for_write[:original].path)
    errors.add(:splash_screen, "Image size should be 960x1600px only") if (dimensions_splash_screen.width != mobile_dimension_width_splash_screen or dimensions_splash_screen.height != mobile_dimension_height_splash_screen)
  end
  
  def image_dimensions_for_login_background
    mobile_dimension_height_login_background,mobile_dimension_width_login_background  = 1600.0, 960.0
    dimensions_login_background = Paperclip::Geometry.from_file(login_background.queued_for_write[:original].path)
    errors.add(:login_background, "Image size should be 960x1600px only") if (dimensions_login_background.width != mobile_dimension_width_login_background or dimensions_login_background.height != mobile_dimension_height_login_background)
  end
  
  def image_dimensions_for_screen_background
    mobile_dimension_height_listing_screen_background, mobile_dimension_width_listing_screen_background  = 1600.0, 960.0
    dimensions_listing_screen_background = Paperclip::Geometry.from_file(listing_screen_background.queued_for_write[:original].path)
    errors.add(:listing_screen_background, "Image size should be 960x1600px only")  if (dimensions_listing_screen_background.width != mobile_dimension_width_listing_screen_background or dimensions_listing_screen_background.height != mobile_dimension_height_listing_screen_background)
  end

  def change_status(mobile_app)
    if mobile_app == "submit_to_store"
      self.submit_to_store!
    elsif mobile_app == "remove_from_store"
      self.remove_from_store!
    end
  end

  def get_events(user,events)
    if user.has_role? :moderator or user.has_role? :event_admin or user.has_role? :db_manager
      apps = self.events.where(:id => events.pluck(:id)).order(start_event_date: :desc) rescue []
    else
      apps = self.events.where(:marketing_app => nil).order(start_event_date: :desc) rescue []
    end  
    apps
  end

  def get_events_for_marketing_app(user,events)
    if user.has_role? :moderator or user.has_role? :event_admin or user.has_role? :db_manager
      apps = self.events.where(:id => events.pluck(:id)).order(start_event_date: :desc) rescue []
    else
      apps = self.events.where(:marketing_app => nil).order(start_event_date: :desc) rescue []
    end  
    apps
  end

  def self.get_mobile_application_name(id)
    MobileApplication.find_by_id(id)
  end

end
