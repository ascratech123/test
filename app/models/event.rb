class Event < ActiveRecord::Base
  require 'review_status'

  resourcify
  serialize :preferences
  
  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am, :end_time_hour, :end_time_minute ,:end_time_am, :event_theme, :event_limit, :event_date_limit
  EVENT_FEATURE_ARR = ['speakers', 'invitees', 'agendas', 'polls', 'conversations', 'faqs', 'awards', 'qnas','feedbacks', 'e_kits', 'abouts', 'galleries', 'notes', 'contacts', 'event_highlights', 'highlight_images', 'emergency_exits','venue']
  REVIEW_ATTRIBUTES = {'template_id' => 'Template', 'app_icon_file_name' => 'App Icon', 'app_icon' => 'App Icon', 'name' => 'Name', 'application_type' => 'Application Type', 'listing_screen_background_file_name' => 'Listing Screen Background', 'listing_screen_background' => 'Listing Screen Background', 'login_background' => 'Login Background', 'login_background_file_name' => 'Login Background', 'login_at' => 'Login At', 'logo' => 'Event Listing Logo', 'inside_logo' => 'Inside Logo', 'logo_file_name' => 'Event Listing Logo', 'inside_logo_file_name' => 'Inside Logo', 'theme_id' => 'Preview Theme', "splash_screen_file_name" => "Splash Screen"}
  FEATURE_TO_MODEL = {"contacts" => 'Contact',"speakers" => 'Speaker',"invitees" => 'Invitee',"agendas" => 'Agenda',"faqs" => 'Faq',"qnas" => 'Qna',"conversations" => 'Conversation',"polls" => 'Poll',"awards" => 'Award',"sponsors" => 'Sponsor',"feedbacks" => 'Feedback',"panels" => 'Panel',"event_features" => 'EventFeature',"e_kits" => 'EKit',"quizzes" => 'Quiz',"favorites" => 'Favorite',"exhibitors" => 'Exhibitor', 'galleries' => 'Image', 'emergency_exits' => 'EmergencyExit', 'attendees' => 'Attendee', 'my_travels' => 'MyTravel', 'custom_page1s' => 'CustomPage1', 'custom_page2s' => 'CustomPage2', 'custom_page3s' => 'CustomPage3', 'custom_page4s' => 'CustomPage4', 'custom_page5s' => 'CustomPage5'}
  COUNTRIES = ["Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burma", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo", "Democratic Republic of the", "Congo", "Republic of the", "Costa Rica", "Cote dIvoire", "Croatia", "Cuba", "Curacao", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "East Timor", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Holy See", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea", "North", "Korea", "South", "Kosovo", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Namibia", "Nauru", "Nepal", "Netherlands", "Netherlands Antilles", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "Norway", "Oman", "Pakistan", "Palau", "Palestinian Territories", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Sint Maarten", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"]
  
  belongs_to :client
  belongs_to :theme
  belongs_to :mobile_application
  has_one :contact
  has_one :emergency_exit
  has_one :qna_wall
  has_one :conversation_wall
  has_one :poll_wall
  has_one :quiz_wall
  has_many :speakers, :dependent => :destroy
  has_many :invitees, :dependent => :destroy
  has_many :attendees, :dependent => :destroy
  has_many :agendas, :dependent => :destroy
  has_many :faqs, :dependent => :destroy
  has_many :qnas, :dependent => :destroy
  has_many :conversations, :dependent => :destroy
  has_many :polls, :dependent => :destroy
  has_many :awards, :dependent => :destroy
  has_many :sponsors, :dependent => :destroy
  has_and_belongs_to_many :users
  has_many :feedbacks, :dependent => :destroy
  has_many :feedback_forms, :dependent => :destroy
  has_many :images, as: :imageable, :dependent => :destroy
  has_many :panels, :dependent => :destroy
  has_many :event_features, :dependent => :destroy
  has_many :feedbacks, :dependent => :destroy
  has_many :e_kits, :dependent => :destroy
  has_many :contacts, :dependent => :destroy 
  has_many :notifications, :dependent => :destroy
  has_many :highlight_images, :dependent => :destroy
  has_many :groupings, :dependent => :destroy
  has_many :quizzes, :dependent => :destroy
  has_many :invitee_structures, :dependent => :destroy
  has_many :favorites, :dependent => :destroy
  has_many :groupings, :dependent => :destroy
  has_many :exhibitors, :dependent => :destroy
  has_many :registration_settings, :dependent => :destroy
  has_many :registrations, :dependent => :destroy
  has_many :user_registrations, :dependent => :destroy
  has_many :analytics, :dependent => :destroy
  has_many :custom_page1s, :dependent => :destroy
  has_many :custom_page2s, :dependent => :destroy
  has_many :custom_page3s, :dependent => :destroy
  has_many :custom_page4s, :dependent => :destroy
  has_many :custom_page5s, :dependent => :destroy
  has_many :chats, :dependent => :destroy
  has_many :invitee_groups, :dependent => :destroy
  has_many :my_travels, :dependent => :destroy
  has_many :telecaller_accessible_columns, :dependent => :destroy
  has_many :campaigns, :dependent => :destroy
  has_many :agenda_tracks, :dependent => :destroy
  has_many :manage_invitee_fields, :dependent => :destroy
  accepts_nested_attributes_for :images
  accepts_nested_attributes_for :event_features

  
  validates :event_name, :client_id, :cities, presence:{ :message => "This field is required." } #:event_code, :start_event_date, :end_event_date, :venues, :pax
  validates :start_event_date,:end_event_date, presence:{ :message => "This field is required." }, :if => Proc.new{|p|p.marketing_app.blank?}
  validates :country_name,:timezone, presence:{ :message => "This field is required." }
  validates :pax, :numericality => { :greater_than_or_equal_to => 0}, :allow_blank => true
  validate :end_event_time_is_after_start_event_time 
  #validates_presence_of :login_at, :on => :create
  validate :image_dimensions
  #validates :event_code, uniqueness: {scope: :client_id}, :allow_blank => true
  # validates :start_event_date, presence: true
  has_attached_file :logo, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(EVENT_LOGO_PATH)
  has_attached_file :inside_logo, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(EVENT_INSIDE_LOGO_PATH)                                       
  validates_attachment_content_type :logo, :content_type => ["image/png"],:message => "please select valid format."
  validates_attachment_content_type :inside_logo, :content_type => ["image/png"],:message => "please select valid format."
  validate :event_count_within_limit, :check_event_date, :on => :create
  before_create :set_preview_theme
  before_save :check_event_content_status#, :add_venues_from_event_venues 
  after_create :update_theme_updated_at, :set_uniq_token, :set_event_category
  after_save :update_login_at_for_app_level, :set_date, :set_timezone_on_associated_tables, :update_last_updated_model

  # after_update :update_time, if: -> { points == 10}
  # scope :thousand_points, -> { where(points: '10').order('invitee_points_time DESC') }

  #before_validation :set_time
  
  scope :ordered, -> { order('start_event_date asc') }
  #default_scope { order('created_at desc') }
  
  include AASM
  aasm :column => :status do
    state :pending, :initial => true
    state :approved
    state :rejected
    state :published
    
    #after_all_transitions :chage_updated_at

    event :approve do
      transitions :from => [:pending], :to => [:approved]
    end 
    event :reject do
      transitions :from => [:pending,:approved], :to => [:rejected]
    end
    event :publish, :after => [:chage_updated_at, :destroy_log_change_for_publish] do
      transitions :from => [:approved], :to => [:published]
    end
    event :unpublish, :after => :create_log_change do
      transitions :from => [:published], :to => [:approved]
    end
  end
  
  def add_venues_from_event_venues
    if self.event_venues.present?
      self.venues = self.event_venues.first.venue
      # self.venues = event_venue
    end
  end

  def event_venue_name
    self.event_venues.pluck(:venue).join('$$$$') if self.event_venues.present?
  end

  # def update_time
  #   self.invitees.each do |invitee|
  #     # invitee_points = invitee.points == 10
  #     invitee_points = invitee.update_column('invitee_points_time', Time.now) if invitee.points == 10
  #   end# if self.invitees.present?
  # end

  # def invitees_with_thousand_points
  #   if self.invitees.present? and (self.end_event_date.present? and self.end_event_date >= Date.today)
  #     self.invitees.where('points >= ? ', 1000)
  #   elsif self.start_event_date.present? and self.end_event_date.present?

  #   end
  # end
  
  def init
    self.status = "pending"
    self.event_theme = "create your own theme"
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def update_theme_updated_at
    self.theme.update_column(:updated_at, Time.now) rescue nil
  end

  def update_login_at_for_app_level
    if self.login_at == "Before Interaction" or self.login_at == "After Highlight"
      self.update_column(:rsvp, "No")
      self.update_column(:rsvp_message, nil)
      self.update_column(:updated_at, Time.now)
    end
    if self.mobile_application.present?
      app_login = self.login_at == 'After Splash' ? 'Yes' : 'No'
      self.mobile_application.update_column(:login_at, app_login)
      self.mobile_application.update_column(:updated_at, Time.now)
      self.mobile_application.events.each do |event|
        login_at = self.login_at || mobile_application.events.first.login_at rescue 'Before Interaction'
        event.update_column(:login_at, login_at)
        #event.update_column(:login_at, self.login_at)
        event.update_column(:updated_at, Time.now) rescue nil
      end
    end
  end

  def set_preview_theme
    self.theme_id = Theme.where(:admin_theme => true, :preview_theme => "yes").first.id rescue nil
  end

  def self.search(params, events)
    event_name, end_date, start_date, order_by, order_by_status = params[:search][:name], params[:search][:end_date], params[:search][:start_date], params[:search][:order_by], params[:search][:order_by_status] if params[:adv_search].present?
    basic = params[:search][:keyword]
    if event_name.present?
      events = events.where("event_name like (?)","%#{event_name}%")
    end
    # events = events.where("event_code like (?)","%#{event_code}%") if event_code.present?
    if end_date.present?
      # events = events.where("end_event_date =?",end_date.to_date)
      events = events.where("end_event_date >=? and end_event_date <= ? ", end_date.to_datetime, (end_date.to_datetime.next_day - 1.minutes))
    end
    if start_date.present?
      # events = events.where("start_event_date =?",start_date.to_date)
      events = events.where("start_event_date >=? and start_event_date <= ? ", start_date.to_datetime, (start_date.to_datetime.next_day - 1.minutes))

    end
    if order_by.present? and order_by == "upcoming"
      events = events.where('start_event_date > ? AND end_event_date > ?',Date.today,Date.today) 
    end

    if order_by.present? and order_by == "past"
      events = events.where('start_event_date < ? AND end_event_date < ?',Date.today, Date.today) 
    end

    if order_by.present? and order_by == "ongoing"
      events = events.where('start_event_date <= ? AND end_event_date >= ?',Date.today,Date.today)
    end

    if order_by_status.present?
      events = events.where("status = ?", order_by_status) 
    end
    if basic.present?
      events = events.where("event_name like (?)", "%#{basic}%") 
    end
    
    events
  end 

  def logo_url(style=:small)
    style.present? ? self.logo.url(style) : self.logo.url
  end

  def inside_logo_url(style=:original)
    style.present? ? self.inside_logo.url(style) : self.inside_logo.url
  end


  def perform_event(event)
    self.approve! if event== "approve"
    self.reject! if event== "reject"
    self.publish! if event == "publish"
    self.unpublish! if event == "unpublish"
  end

  def add_features(params)
    if params[:event].present?
      params[:event][:features] = params[:event][:features].present? ? params[:event][:features] : []
      already_feature = self.event_features.pluck(:name) 
      feature_delete = already_feature.select { |elem| (!params[:event][:features].include?(elem) and elem != "my_calendar")  }
      feature_delete.each {|f| self.event_features.where(:name => f).destroy_all}
      feature_to_add = params[:event][:features] - already_feature if params[:event][:features].present?
      feature_to_add.each_with_index do |f,i|
        seq = self.event_features.present? ? self.event_features.pluck(:sequence).compact.max.to_i + 1 : 1  
        f = "venue" if f == "emergency_exits"
        ef = self.event_features.new(name: f, page_title: Client::display_hsh1[f], sequence: seq, status: (f == "my_calendar" ? "deactive" : "active"))
        if self.save
          default_icon = (self.default_feature_icon == "custom" ? "new" : self.default_feature_icon )
          if self.default_feature_icon != "owns" and self.default_feature_icon != "new_menu"
            ef.update_attributes(:menu_icon => File.new("public/menu_icons/#{default_icon}_icons/#{Client::menu_icon[ef.name]}.png","rb"), :main_icon => File.new("public/main_icons/#{default_icon}_icons/#{Client::menu_icon[ef.name]}.png","rb")) rescue nil
          elsif self.default_feature_icon == "owns" or self.default_feature_icon == "new_menu"
            ef.menu_icon = nil
            ef.main_icon = nil
            ef.save
          end
        end if !(already_feature.include?(f)) 
      end
    else
      self.event_features.where("name != ?", "my_calendar").destroy_all
      self.update_column(:default_feature_icon, "new_menu")
    end
  end

  def add_single_features(params)
    unless self.event_features.pluck(:name).include?(params[:enable_event])
      seq = self.event_features.present? ? self.event_features.pluck(:sequence).compact.max.to_i + 1 : 1 rescue 1
      feature = params["enable_event"] == 'images' ? 'galleries' : params["enable_event"]
      default_status = (feature == "my_calendar" ? "deactive" : "active" )
      feature = self.event_features.new(name: feature, page_title: Client::display_hsh1[feature], sequence: seq, status: default_status)
      default_icon = (self.default_feature_icon == "custom" ? "new" : self.default_feature_icon )
      if feature.save
        if feature.name == "venue"
          if self.default_feature_icon != "owns" and self.default_feature_icon != "new_menu"
            feature.update_attributes(:menu_icon => File.new("public/menu_icons/#{default_icon}_icons/Venue.png","rb"), :main_icon => File.new("public/main_icons/#{default_icon}_icons/Venue.png","rb")) rescue nil
          elsif self.default_feature_icon == "owns" and self.default_feature_icon == "new_menu"
            feature.menu_icon = nil
            feature.main_icon = nil
            feature.save
          end
        else
          if self.default_feature_icon != "owns" and self.default_feature_icon != "new_menu"
            feature.update_attributes(:menu_icon => File.new("public/menu_icons/#{default_icon}_icons/#{Client::menu_icon[feature.name]}.png","rb"), :main_icon => File.new("public/main_icons/#{default_icon}_icons/#{Client::menu_icon[feature.name]}.png","rb")) rescue nil
          elsif self.default_feature_icon == "owns" and self.default_feature_icon == "new_menu"
            feature.menu_icon = nil
            feature.main_icon = nil
            feature.save
          end
        end
      end
    end
  end

  def remove_single_features(params)
    features = self.event_features
    feature_name = (params["disable_event"] == "images" ? "galleries" : params["disable_event"])    
    feature = features.find_by_name(feature_name)
    feature.destroy if feature.present?
    if self.event_features.blank?
      self.update_column(:default_feature_icon, "new_menu")
    end
  end

  def self.sort_by_type(type,events)
    if type == "upcoming_event"
      events = events.where('start_event_date > ? and end_event_date > ?',Date.today, Date.today)
    elsif type == "ongoing_event"
      events = events.where('start_event_date <= ? and end_event_date >= ?',Date.today,Date.today)
    else
      events = events.where('end_event_date < ?',Date.today)
    end
    events
  end

  def set_status_for_licensee
    self.status = "approved"    
  end
  
  def set_features_default_list()
    default_features = ["abouts", "agendas", "speakers", "faqs", "galleries", "feedbacks", "e_kits","conversations","polls","awards","invitees","qnas", "notes", "contacts", "event_highlights","sponsors", "my_profile", "qr_code","quizzes","favourites","exhibitors",'venue', 'leaderboard', "custom_page1s", "custom_page2s", "custom_page3s","custom_page4s","custom_page5s", "chats", "my_travels","social_sharings", "activity_feeds"]
    self.marketing_app == true ? default_features.push("all_events") : default_features
  end

  def set_features_static_list()
    static_features = ["chat", "travel", "exhibitionguide"]
  end

  def set_features
    present_feature = self.event_features.pluck(:name) 
  end
  
  def set_time(start_event_date, start_time_hour, start_time_minute, start_time_am, end_event_date, end_time_hour, end_time_minute, end_time_am)
    # start_event_date = self.start_event_date.to_date if self.start_event_date.present?
    # end_event_date = self.end_event_date.to_date if self.end_event_date.present?
    start_event_time = "#{start_event_date} #{start_time_hour.gsub(':', "") rescue nil}:#{start_time_minute.gsub(':', "") rescue nil}:#{0} #{start_time_am}" if start_event_date.present?
    end_event_time = "#{end_event_date} #{end_time_hour.gsub(':', "") rescue nil}:#{end_time_minute.gsub(':', "") rescue nil}:#{0} #{end_time_am}" if end_event_date.present?
    if start_event_date.present? and [345, 360, 367, 173, 165, 168, 364, 365, 368, 333].include? self.id
      self.start_event_time = start_event_time
    elsif start_event_date.present?
      self.start_event_time = start_event_time.to_datetime
    end
    if end_event_date.present? and [345, 360, 367, 173, 165, 168, 364, 365, 368, 333].include? self.id
      self.end_event_time = end_event_time
    elsif end_event_date.present?
      self.end_event_time = end_event_time.to_datetime 
    end
  end

  def end_event_time_is_after_start_event_time
    return if start_event_date.blank? || end_event_date.blank? #|| start_event_time.blank? || end_event_time.blank?
    if self.start_event_date.present? and self.end_event_date.present? and self.start_event_time.present? and self.end_event_time.present?
      if  self.start_event_time >= self.end_event_time
        errors.add(:end_event_date, "cannot be before the event start time")
      end
    end
  end

  def check_event_date
    if (User.current.has_role? "licensee_admin" and User.current.licensee_end_date.present?)
      if User.current.licensee_end_date < self.end_event_date
        errors.add(:event_date_limit, "Events end date needs to be between your licenseed end date.")
      else
        self.errors.delete(:event_date_limit)
      end
    end
  end

  def check_event_content_status
    features = self.event_features.pluck(:name) - ['qnas', 'conversations', 'my_profile', 'qr_code','networks','favourites','my_calendar', 'leaderboard', 'custom_page1s', 'custom_page2s', 'custom_page3s', 'custom_page4s', 'custom_page5s', 'social_sharings', 'notes', 'chats', 'activity_feeds','all_events']
    not_enabled_feature = Event::EVENT_FEATURE_ARR - features
    #features += ['contacts', 'emergency_exit', 'event_highlights', 'highlight_images']
    count = 0
    total_content_count = features.count
    content_missing_arr = []
    features.each do |feature|
      feature = 'images' if feature == 'galleries'
      condition = self.association(feature).count <= 0 if !(feature == 'abouts' or feature == 'qr_codes' or feature == 'notes' or feature == 'event_highlights' or feature == 'my_calendar' or feature == 'venue' or feature == 'social_sharings' or feature == 'all_events') and (feature != 'emergency_exits' and feature != 'emergency_exit')
      condition, feature = EmergencyExit.where(:event_id => self.id).blank?, 'emergency_exits' if feature == 'emergency_exits' or feature == 'emergency_exit'
      if (condition or (feature == 'abouts' and self.about.blank? or ((feature == 'event_highlights' and self.description.blank?) )))
        count += 1
        content_missing_arr << feature
      end
    end
    percent = (((count/total_content_count.to_f) * 100) == 0.0)? 100 : (100 - ((count/total_content_count.to_f) * 100)) if total_content_count != 0
    [content_missing_arr, not_enabled_feature, (percent.to_i/10) * 10]
  end

  # def old_review_look_and_feel
  #   total = 3.0
  #   count = 0
  #   count += 1 if !self.theme.is_preview?
  #   count += 1 if self.inside_logo.present?
  #   count += 1 if self.logo.present?
  #   ((count/total) * 100).to_i
  # end

  
  def review_look_and_feel
    if self.mobile_application.present? and self.mobile_application.application_type == 'multi event'
      feature_arr = ['logo_file_name', 'inside_logo_file_name']
    else
      feature_arr = ['inside_logo_file_name']
    end
    review_arr = ReviewStatus.review(self, feature_arr)
    review_arr[0] = (review_arr[0]/2)
    review_arr[0] = review_arr[0].to_i + 50 if !self.theme.is_preview?
    review_arr[1] << 'theme_id' if self.theme.is_preview?
    review_arr
  end

  def review_features
    self.event_features.where("name != ?", "my_calendar").present? ? 100 : 0
  end

  def review_menus
    percentage = 0
    #percentage = 100 if self.menu_saved == "true"
    #percentage
    total = 0
    features = self.event_features
    features = features.where("name NOT IN (?)", ["event_highlights","my_calendar","chats","social_sharings"])
    feature_length = features.length
    total = feature_length * 2 if feature_length.present?
    count = 0
    missing_data = []
    features.each do |feature|
      feature.menu_icon.present? ? count = count + 1 : (missing_data << {:feature => feature.name, :icon => "Drawer Icon"})
      if feature.menu_icon_visibility == "yes" 
        feature.main_icon.present? ? count = count + 1 : (missing_data << {:feature => feature.name, :icon => "Menu Icon"})
      end
      if ["contacts","venue"].include?(feature.name) and (total > 0)
        total = total - 1
      end
    end
    percentage = (count * 100)/(total)  if total != 0
    [percentage,missing_data]
  end

  def review_status(type)
    case type
      when 'app_info'
        per = self.mobile_application.review_status[0]
      when 'look_and_feel'
        per = self.review_look_and_feel[0]
      when 'features'
        per = self.review_features
      when 'menus'
        per = self.review_menus[0]
      when 'content'
        per = self.check_event_content_status[2]
      when 'store_info'
        per = 100
    end
    per
  end

  def avg_review
    if self.mobile_application.present?
      total = 5
      per = self.mobile_application.review_status[0] + self.review_look_and_feel[0] + self.review_features + self.review_menus[0] + self.check_event_content_status[2]
    (((per/total) / 10) * 10)
    end
  end

  def image_dimensions
    if self.inside_logo_file_name_changed?  
      inside_logo_dimension_height  = 300.0
      inside_logo_dimension_width = 1280.0
      dimensions = Paperclip::Geometry.from_file(inside_logo.queued_for_write[:original].path)
      if (dimensions.width != inside_logo_dimension_width or dimensions.height != inside_logo_dimension_height)
        errors.add(:inside_logo, "Image size should be 1280x300px only") if self.errors['inside_logo'].blank?
      else
        self.errors.delete(:inside_logo)
      end
    end
    if self.logo_file_name_changed?  
      logo_dimension_height  = 200.0
      logo_dimension_width = 200.0
      dimensions = Paperclip::Geometry.from_file(logo.queued_for_write[:original].path)
      if (dimensions.width != logo_dimension_width or dimensions.height != logo_dimension_height)
        errors.add(:logo, "Image size should be 200x200px only") if self.errors['logo'].blank?
      else
        self.errors.delete(:logo)  
      end
    end
  end

  def decide_seq_no(seq_type,feature,featue_type)
    if featue_type == Winner
      award = feature.award
      objects = featue_type.where(:award_id => award.id)
    elsif featue_type == Image
      event = feature.imageable
      objects = featue_type.where(:imageable_id => event.id)
    elsif featue_type == AgendaTrack
      event = feature.event
       objects = featue_type.joins(:agendas).where(:event_id => event.id,:agenda_date =>feature.agenda_date.to_date).uniq.order(:sequence)
    else
      event = feature.event
      objects = featue_type.where(:event_id => event.id)
    end
    ids = objects.pluck(:id) 
    position = ids.index(feature.id)
    if featue_type == AgendaTrack
      if seq_type == "up"
        previous_sp = objects.find_by_id(ids[position.to_i - 1])
        old_seq = previous_sp.sequence
        previous_sp.update(:sequence => feature.sequence)
        feature.update(:sequence => old_seq)
        for agenda in feature.agendas
          agenda.update_attribute(:updated_at, Time.now.in_time_zone('UTC'))
        end
      else
        next_sp = objects.find_by_id(ids[position.to_i + 1])
        next_seq = next_sp.sequence
        next_sp.update(:sequence => feature.sequence)
        feature.update(:sequence => next_seq)
        for agenda in feature.agendas
          agenda.update_attribute(:updated_at, Time.new.in_time_zone('UTC'))
        end
      end if ids.length > 1
    else
      if seq_type == "up"
        previous_sp = objects.find_by_id(ids[position.to_i - 1])
        old_seq = previous_sp.sequence
        previous_sp.update(:sequence => feature.sequence)
        feature.update(:sequence => old_seq)
      else
        next_sp = objects.find_by_id(ids[position.to_i + 1])
        next_seq = next_sp.sequence
        next_sp.update(:sequence => feature.sequence)
        feature.update(:sequence => next_seq)
      end if ids.length > 1 
    end
  end

  def chage_updated_at
    self.theme.update_column(:updated_at, Time.now)
    ["contacts","speakers","invitees","agendas","faqs","qnas","conversations","polls","awards","sponsors","feedbacks","panels","event_features","e_kits","quizzes","favorites","exhibitors",'galleries', 'emergency_exits', 'attendees', 'my_travels', 'custom_page1s', 'custom_page2s', 'custom_page3s', 'custom_page4s', 'custom_page5s'].each do |t|
      # query = "UPDATE #{t} SET updated_at = '#{Time.now.strftime("%Y-%m-%d %T")}' WHERE event_id = #{self.id};"
      # ActiveRecord::Base.connection.execute(query)
      FEATURE_TO_MODEL[t].constantize.where(:event_id => self.id).update_all(:updated_at => Time.now) if t != 'galleries'
      FEATURE_TO_MODEL[t].constantize.where(:imageable_id => self.id, :imageable_type => 'Event').update_all(:updated_at => Time.now) if t == 'galleries'
    end
    #query = "UPDATE contacts,speakers,invitees,agendas,faqs,qnas,conversations,polls,awards,sponsors,feedbacks,panels,event_features,e_kits,quizzes,favorites,exhibitors SET contacts.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  speakers.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  invitees.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  agendas.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  faqs.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  qnas.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  conversations.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  polls.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  awards.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  sponsors.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  feedbacks.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  panels.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  event_features.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  e_kits.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  quizzes.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  favorites.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  exhibitors.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}' WHERE contacts.event_id = #{self.id} AND speakers.event_id = #{self.id} AND invitees.event_id = #{self.id} AND agendas.event_id = #{self.id} AND faqs.event_id = #{self.id} AND qnas.event_id = #{self.id} AND conversations.event_id = #{self.id} AND polls.event_id = #{self.id} AND awards.event_id = #{self.id} AND sponsors.event_id = #{self.id} AND feedbacks.event_id = #{self.id} AND panels.event_id = #{self.id} AND event_features.event_id = #{self.id} AND e_kits.event_id = #{self.id} AND quizzes.event_id = #{self.id} AND favorites.event_id = #{self.id} AND exhibitors.event_id = #{self.id};"
    #ActiveRecord::Base.connection.execute(query)
  end

  def create_log_change
    LogChange.create(:changed_data => nil, :resourse_type => "Event", :resourse_id => self.id, :user_id => nil, :action => "destroy") rescue nil
  end

  def destroy_log_change_for_publish
    log_changes = LogChange.where(:resourse_type => "Event", :resourse_id => self.id, :action => "destroy")
    log_changes.each{|l| l.update_column("action", "unpublished")}
    #log_changes.destroy_all
  end

  def add_default_invitee
    invitee = self.invitees.new(name_of_the_invitee: "Preview", email: "preview@previewapp.com", password: "preview", invitee_password: "preview", :first_name => 'Preview', :last_name => 'Invitee')
    invitee.save rescue ""
  end

  def get_agenda
    Agenda.where(:event_id => self.id).pluck(:agenda_type).uniq.compact rescue []
  end

  def get_event_agenda_tracks
    AgendaTrack.joins(:agendas).where(:event_id => self.id)
  end
  
  def event_count_within_limit
    if (User.current.has_role? "licensee_admin" and User.current.no_of_event.present?) or (self.client.licensee.present? and self.client.licensee.no_of_event.present?)
      clients = Client.with_roles(User.current.roles.pluck(:name), User.current).uniq
      event_count = clients.map{|c| c.events.count}.sum
      if (User.current.no_of_event.present? and User.current.no_of_event <= event_count) or (self.client.licensee.present? and self.client.licensee.no_of_event <= event_count)
        errors.add(:event_limit, "You have crossed your events limit kindly contact.")
        # errors.add(:event_limit, "Exceeded the event limit: #{User.current.no_of_event} ")
      else
        self.errors.delete(:event_limit)
      end 
    end
  end

  def get_event_feature_status
    calendar = self.event_features.where(:name => "my_calendar")
    if calendar.present?
      calendar.first.menu_icon_visibility.downcase rescue ""
    else
      ""
    end
  end
  def validate_rsvp_text(params)
    if params[:event].present? and params[:event][:rsvp_message].blank?
      errors.add(:rsvp_message, "This field is required.")
      return false
    else
      errors.delete(:rsvp_message)
      return true
    end 
  end

  def self.get_event_by_id(id)
    self.find_by_id(id)
  end

  def self.get_associated_module_data(feature,id)
    feature.find_by_id(id)
  end

  def set_uniq_token
    loop do
      uniq_token = Devise.friendly_token
      break uniq_token if Event.pluck(:token).exclude?(uniq_token)
    end
    self.update_column(:token, uniq_token) rescue nil
  end
  # def review_event_features_content
  #   features = self.event_features
  #   count = 0
  #   total_content_count = features.count
  #   content_missing_arr = {}
  #   features.each do |feature|
  #     content_missing_arr[feature.name] = feature.review_status
  #   end
  #   content_missing_arr
  # end

  def get_licensee_admin
    self.client.licensee rescue nil
  end

  def name_with_email
    users = []
    self.invitees.each do |user|
      if user.last_name.present?
        users << "#{user.first_name.to_s + " " + user.last_name.to_s}(#{user.email})"
      else
        users << "#{user.first_name}(#{user.email})"
      end
    end
    users
  end

  def set_timezone_on_associated_tables
    if self.timezone_changed?
      self.update_column("timezone", self.timezone.titleize) if !self.timezone.include? "US"
      self.update_column("timezone_offset", ActiveSupport::TimeZone[self.timezone].at(self.start_event_time).utc_offset)
      display_time_zone = self.display_time_zone
      #["agendas", "chats", "conversations", "faqs", "feedbacks", "polls", "qnas", "quizzes", "notifications", "invitees", "speakers"]
      for table_name in ["agendas", "chats", "conversations", "notifications"]
        table_name.classify.constantize.where(:event_id => self.id).each do |obj|
          obj.update_column("event_timezone", self.timezone)
          obj.update_column("event_timezone_offset", self.timezone_offset)
          obj.update_column("event_display_time_zone", display_time_zone)
          obj.update_column("updated_at", Time.now)
          obj.update_last_updated_model
          # obj.comments.each{|c| c.update_column("updated_at", Time.now)} if table_name == "conversations"
          for c in obj.comments
            c.update_column("updated_at", Time.now)
            Rails.cache.delete("formatted_created_at_with_event_timezone_#{c.id}")
            Rails.cache.delete("formatted_updated_at_with_event_timezone_#{c.id}")
          end if table_name == "conversations"
        end
      end
    end
  end

  def set_date
    self.update_column(:start_event_date, self.start_event_time)
    self.update_column(:end_event_date, self.end_event_time)
  end

  def about_date
    if self.start_event_date.to_date != self.end_event_date.to_date
      "#{self.start_event_date.strftime('%d %b')} - #{self.end_event_date.strftime('%d %b %Y')}"
    else
      self.start_event_date.strftime('%A, %d %b %Y')
    end
  end

  def self.set_event_category
    Event.find_each do |event|
      event.set_event_category rescue nil
    end
  end

  def set_event_category
    time_now = Time.now.in_time_zone(self.timezone).strftime("%d-%m-%Y %H:%M").to_datetime
    prev_event_category  = self.event_category
    if self.start_event_time.present? and self.end_event_time.present?
      if self.start_event_time <= time_now and self.end_event_time >= time_now
        self.update_column("event_category","Ongoing")
      elsif self.start_event_time > time_now
        self.update_column("event_category","Upcoming")
      elsif self.end_event_time < time_now
        self.update_column("event_category","Past")
      end
      self.update_column("updated_at",Time.now) if (prev_event_category != self.event_category)
    end
  end

  def event_start_time_in_utc
    event_time_in_timezone = self.start_event_time
    difference_in_seconds = Time.now.utc.utc_offset - Time.now.in_time_zone(self.timezone).utc_offset
    if difference_in_seconds < 0
      difference_in_hours = (difference_in_seconds.to_f/60/60).abs
      self.start_event_date - difference_in_hours.hours
    else
      difference_in_hours = (difference_in_seconds.to_f/60/60)
      self.start_event_date + difference_in_hours.hours
    end
  end

  def display_time_zone
    event_tz = "GMT +00:00"
    for tz in ActiveSupport::TimeZone.all.uniq{|e| ["GMT#{e.at(self.start_event_time).formatted_offset}"]}
      event_tz = "GMT#{tz.at(self.start_event_time).formatted_offset}".gsub("GMT", "GMT ") if tz.name == self.timezone
    end
    return event_tz
  end

  #def display_time_zone
  #  Time.now.in_time_zone(self.timezone).strftime("GMT %:z")
  #end
  def create_marketing_app_event
    self.marketing_app = true
    self.event_name = "test"
    self.cities = "Mumbai"
    #self.start_event_date = "2016-10-11 00:00:00"
    self.start_event_time = "2016-10-11 00:00:00"
    self.country_name = "India"
    self.timezone = "Chennai"
    self.status = "approved" 
    if self.save
      result = "true"
    else
      result = "false"
    end
    result
  end
end