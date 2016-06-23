class Event < ActiveRecord::Base
  require 'review_status'

  resourcify
  serialize :preferences
  
  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am, :end_time_hour, :end_time_minute ,:end_time_am, :event_theme, :event_limit
  EVENT_FEATURE_ARR = ['speakers', 'invitees', 'agendas', 'polls', 'conversations', 'faqs', 'awards', 'qnas','feedbacks', 'e_kits', 'abouts', 'galleries', 'notes', 'contacts', 'event_highlights', 'highlight_images', 'emergency_exits','venue']
  REVIEW_ATTRIBUTES = {'template_id' => 'Template', 'app_icon_file_name' => 'App Icon', 'app_icon' => 'App Icon', 'name' => 'Name', 'application_type' => 'Application Type', 'listing_screen_background_file_name' => 'Listing Screen Background', 'listing_screen_background' => 'Listing Screen Background', 'login_background' => 'Login Background', 'login_background_file_name' => 'Login Background', 'login_at' => 'Login At', 'logo' => 'Event Listing Logo', 'inside_logo' => 'Inside Logo', 'logo_file_name' => 'Event Listing Logo', 'inside_logo_file_name' => 'Inside Logo', 'theme_id' => 'Preview Theme', "splash_screen_file_name" => "Splash Screen"}


  belongs_to :client
  belongs_to :theme
  belongs_to :mobile_application
  has_one :contact
  has_one :emergency_exit
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
  accepts_nested_attributes_for :images
  accepts_nested_attributes_for :event_features

  
  validates :event_name, :client_id, :cities, :start_event_date,:end_event_date, presence:{ :message => "This field is required." } #:event_code, :start_event_date, :end_event_date, :venues, :pax
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
  validate :event_count_within_limit, :on => :create
  before_create :set_preview_theme
  before_save :check_event_content_status
  after_create :update_theme_updated_at, :set_uniq_token
  after_save :update_login_at_for_app_level
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
    event :publish, :after => :chage_updated_at do
      transitions :from => [:approved], :to => [:published]
    end
    event :unpublish, :after => :create_log_change do
      transitions :from => [:published], :to => [:approved]
    end
  end 

  
  def init
    self.status = "pending"
    self.event_theme = "create your own theme"
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
        event.update_column(:login_at, self.login_at)
        event.update_column(:updated_at, Time.now) rescue nil
      end
    end
  end

  def set_preview_theme
    self.theme_id = Theme.where(:admin_theme => true, :preview_theme => "yes").first.id rescue nil
  end

  def self.search(params, events)
    event_name, event_code, start_date, order_by, order_by_status = params[:search][:name], params[:search][:code], params[:search][:start_date], params[:search][:order_by], params[:search][:order_by_status] if params[:adv_search].present?
    basic = params[:search][:keyword]
    events = events.where("event_name like (?)","%#{event_name}%") if event_name.present?
    events = events.where("event_code like (?)","%#{event_code}%") if event_code.present?
    events = events.where("start_event_date =?",start_date) if start_date.present?
    events = events.where('start_event_date > ?',Date.today) if order_by.present? and order_by == "upcoming"
    events = events.where('start_event_date < ?',Date.today) if order_by.present? and order_by == "past"
    events = events.where('start_event_date = ?',Date.today) if order_by.present? and order_by == "ongoing"
    events = events.where("status = ?", order_by_status) if order_by_status.present?
    events = events.where("event_name like (?) or event_code like (?)", "%#{basic}%", "%#{basic}%") if basic.present?
    events
  end 

  def logo_url(style=:small)
    style.present? ? self.logo.url(style) : self.logo.url
  end

  def inside_logo_url(style=:small)
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
    default_features = ["abouts", "agendas", "speakers", "faqs", "galleries", "feedbacks", "e_kits","conversations","polls","awards","invitees","qnas", "notes", "contacts", "event_highlights","sponsors", "my_profile", "qr_code","quizzes","favourites","exhibitors",'venue', 'leaderboard', "custom_page1s", "custom_page2s", "custom_page3s","custom_page4s","custom_page5s", "chats", "my_travels","social_sharings"]
    default_features
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
    self.start_event_time = "#{start_event_date} #{start_time_hour.gsub(':', "") rescue nil}:#{start_time_minute.gsub(':', "") rescue nil}:#{0} #{start_time_am}" if start_event_date.present?
    self.end_event_time = "#{end_event_date} #{end_time_hour.gsub(':', "") rescue nil}:#{end_time_minute.gsub(':', "") rescue nil}:#{0} #{end_time_am}" if end_event_date.present?
  end

  def end_event_time_is_after_start_event_time
    return if start_event_date.blank? || end_event_date.blank? #|| start_event_time.blank? || end_event_time.blank?
    if self.start_event_date.present? and self.end_event_date.present? and self.start_event_time.present? and self.end_event_time.present?
      if  self.start_event_time >= self.end_event_time
        errors.add(:end_event_date, "cannot be before the event start time")
      end
    end
  end

  def check_event_content_status
    features = self.event_features.pluck(:name) - ['qnas', 'conversations', 'my_profile', 'qr_code','networks','favourites','my_calendar', 'leaderboard', 'custom_page1s', 'custom_page2s', 'custom_page3s', 'custom_page4s', 'custom_page5s']
    not_enabled_feature = Event::EVENT_FEATURE_ARR - features
    #features += ['contacts', 'emergency_exit', 'event_highlights', 'highlight_images']
    count = 0
    total_content_count = features.count
    content_missing_arr = []
    features.each do |feature|
      feature = 'images' if feature == 'galleries'
      condition = self.association(feature).count <= 0 if !(feature == 'abouts' or feature == 'qr_codes' or feature == 'notes' or feature == 'event_highlights' or feature == 'my_calendar' or feature == 'venue' or feature == 'social_sharings') and (feature != 'emergency_exits' and feature != 'emergency_exit')
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
      inside_logo_dimension_height  = 140.0
      inside_logo_dimension_width = 600.0
      dimensions = Paperclip::Geometry.from_file(inside_logo.queued_for_write[:original].path)
      if (dimensions.width != inside_logo_dimension_width or dimensions.height != inside_logo_dimension_height)
        errors.add(:inside_logo, "Image size should be 600x140px only") if self.errors['inside_logo'].blank?
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
    else
      event = feature.event
      objects = featue_type.where(:event_id => event.id)
    end
    ids = objects.pluck(:id) 
    position = ids.index(feature.id)
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

  def chage_updated_at
    self.theme.update_column(:updated_at, Time.now)
    ["contacts","speakers","invitees","agendas","faqs","qnas","conversations","polls","awards","sponsors","feedbacks","panels","event_features","e_kits","quizzes","favorites","exhibitors"].each do |t|
      query = "UPDATE #{t} SET updated_at = '#{Time.now.strftime("%Y-%m-%d %T")}' WHERE event_id = #{self.id};"
      ActiveRecord::Base.connection.execute(query)
    end
    #query = "UPDATE contacts,speakers,invitees,agendas,faqs,qnas,conversations,polls,awards,sponsors,feedbacks,panels,event_features,e_kits,quizzes,favorites,exhibitors SET contacts.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  speakers.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  invitees.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  agendas.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  faqs.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  qnas.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  conversations.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  polls.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  awards.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  sponsors.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  feedbacks.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  panels.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  event_features.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  e_kits.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  quizzes.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  favorites.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}',  exhibitors.updated_at =  '#{Time.now.strftime("%Y-%M-%d %T")}' WHERE contacts.event_id = #{self.id} AND speakers.event_id = #{self.id} AND invitees.event_id = #{self.id} AND agendas.event_id = #{self.id} AND faqs.event_id = #{self.id} AND qnas.event_id = #{self.id} AND conversations.event_id = #{self.id} AND polls.event_id = #{self.id} AND awards.event_id = #{self.id} AND sponsors.event_id = #{self.id} AND feedbacks.event_id = #{self.id} AND panels.event_id = #{self.id} AND event_features.event_id = #{self.id} AND e_kits.event_id = #{self.id} AND quizzes.event_id = #{self.id} AND favorites.event_id = #{self.id} AND exhibitors.event_id = #{self.id};"
    #ActiveRecord::Base.connection.execute(query)
  end

  def create_log_change
    LogChange.create(:changed_data => nil, :resourse_type => "Event", :resourse_id => self.id, :user_id => nil, :action => "destroy") rescue nil
  end

  def add_default_invitee
    invitee = self.invitees.new(name_of_the_invitee: "Preview", email: "preview@previewapp.com", password: "preview", invitee_password: "preview", :first_name => 'Preview', :last_name => 'Invitee')
    invitee.save rescue ""
  end

  def get_agenda
    Agenda.where(:event_id => self.id).pluck(:agenda_type).uniq.compact rescue []
  end
  
  def event_count_within_limit
    if (User.current.has_role? "licensee_admin" and User.current.no_of_event.present?)
      clients = Client.with_roles(User.current.roles.pluck(:name), User.current).uniq
      event_count = clients.map{|c| c.events.count}.sum
      if User.current.no_of_event <= event_count
        errors.add(:event_limit, "Exceeded the event limit: #{User.current.no_of_event} ")
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
  
end
