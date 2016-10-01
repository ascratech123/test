class Invitee < ActiveRecord::Base
  include AASM
  require 'vpim/vcard'
  require 'rqrcode_png'
  require 'qr_code' 
  
  attr_accessor :password, :invitee_searches_page
  
  belongs_to :event
  has_many :devices, :class_name => 'Device', :foreign_key => 'email', :primary_key => 'email'
  has_many :conversations, :class_name => 'Conversation', :foreign_key => 'user_id'  
  has_many :comments, :class_name => 'Comment', :foreign_key => 'user_id'  
  has_many :favorites, as: :favoritable, :dependent => :destroy
  has_many :ratings, :class_name => 'Rating', :foreign_key => 'rated_by'  
  has_one :my_travel, :dependent => :destroy
  has_many :analytics, :dependent => :destroy

  
  before_validation :set_auto_generated_password#, :if => self.new_record? and self.password.blank? and self.email.present?
  before_validation :downcase_email

  validates_presence_of :first_name, :last_name ,:message => "This field is required."
  validates :email,
            :format => {
            :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
            :message => "Sorry, this doesn't look like a valid email." }
  validates :email, uniqueness: {scope: [:event_id]}
  validates :mobile_no,:numericality => true,:length => { :minimum => 10, :maximum => 10}, :allow_blank => true
  
  #has_attached_file :qr_code, {:styles => {:large => "200x200>",
  #                                       :small => "60x60>", 
  #                                       :thumb => "54x54>"}}.merge(INVITEE_QR_CODE_PATH)

  has_attached_file :qr_code, {:styles => {}}.merge(INVITEE_QR_CODE_PATH)
  has_attached_file :profile_pic, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(INVITEE_IMAGE_PATH)
  validates_attachment_content_type :qr_code, :content_type => ["image/png"],:message => "please select valid format."
  validates_attachment_content_type :profile_pic, :content_type => ["image/png", "image/jpg", "image/jpeg"],:message => "please select valid format."
  # validate :image_dimensions

  default_scope { order('created_at desc') }
  
  before_create :ensure_authentication_token, :generate_key
  # after_create :set_event_timezone
  before_save :encrypt_password
  
  before_save :set_full_name
  after_save :clear_password, :update_favorite
  after_save :generate_qr_code
  after_save :update_event_updated_at
  # after_create :send_password_to_invitee
  before_destroy :update_event_updated_at
  
  aasm :column => :visible_status do  # defaults to aasm_state
    state :active, :initial => true
    state :deactive
    
    event :active do
      transitions :from => [:deactive], :to => [:active]
    end 
     event :deactive do
      transitions :from => [:active], :to => [:deactive]
    end
  end 
  
  # def image_dimensions
  #   if self.profile_pic_file_name_changed? 
  #     height_profile_pic, width_profile_pic  = 300.0, 300.0
  #     dimensions_profile_pic = Paperclip::Geometry.from_file(profile_pic.queued_for_write[:original].path)
  #     if (dimensions_profile_pic.width < width_profile_pic or dimensions_profile_pic.height < height_profile_pic)
  #       errors.add(:profile_pic, "Width or Height must be 300x300 or greater")
  #     end
  #   end
  # end
    
  def facebook
    self.facebook_id rescue ""
  end
  def google_plus
    self.google_id rescue ""
  end
  def linkedin
    self.linkedin_id rescue ""
  end

  def twitter
    self.twitter_id rescue ""
  end

  def city
    self.street rescue ""
  end

  def description
    self.about rescue ""
  end

  def phone_number
    self.mobile_no rescue ""
  end

  def logged_in
    self.analytics.where(:action => 'Login').present? ? 'Yes' : 'No' rescue ""
  end 

  def Profile_pic_URL
    self.profile_pic.url.present? and self.profile_pic.url != "/profile_pics/original/missing.png" ? self.profile_pic.url : ""
  end

  def profile_picture
    self.profile_pic.url rescue ""
  end

  def Remark
    self.remark
  end

  def feedback_last_updated_at
    feedbacks = UserFeedback.unscoped.where(:user_id => self.id).order("updated_at")
    feedbacks.last.updated_at if feedbacks.present?
  end

  def feedback_last_updated_at_with_event_timezone
    feedbacks = UserFeedback.unscoped.where(:user_id => self.id).order("updated_at")
    feedbacks.last.updated_at.in_time_zone(self.event.timezone) if feedbacks.present?
  end
  
  def self.get_invitee_by_id(id)
    Invitee.find_by_id(id)
  end

  def set_full_name
    self.name_of_the_invitee = self.first_name + " " + self.last_name  
  end

  def qr_code_url(style=nil)
    style.present? ? self.qr_code.url(style) : self.qr_code.url
  end

  def profile_pic_url(style=:small)
    style.present? ? self.profile_pic.url(style) : self.profile_pic.url
  end

  def set_auto_generated_password
    if self.new_record? and self.password.blank? and self.email.present?
      event_ids = self.event.mobile_application.events.pluck(:id) rescue []
      other_invitees = Invitee.where('email = ? and event_id IN (?) and invitee_password IS NOT NULL', self.email, event_ids)
      if other_invitees.present?
        pwd = other_invitees.first.invitee_password
      else
        pwd = self.email.first(4) rescue rand.to_s[2..5]
        pwd += rand.to_s[2..7]
      end
      self.invitee_password = pwd 
      self.password = pwd #"password"
    end
  end

  def send_password_to_invitee
    # if self.event_id != 304
    #   other_invitees = Invitee.where('email = ? and event_id = ? and email_send = ? and invitee_password IS NOT NULL', self.email, self.event_id, 'true')
    #   if other_invitees.blank? and self.provider.blank?
    #    UserMailer.send_password_invitees(self).deliver_now
    #     self.update_column(:email_send, 'true')
    #   end
    # end
  end

  def set_invitee_password
    if self.password.present?
      self.invitee_password = self.password 
      # self.email_send = "false"
    end
  end

  def self.search(params,invitees)
    invitees = invitees.where(company_name: params[:search][:company_name]) if params[:search][:company_name].present?
    invitees = invitees.where(designation: params[:search][:designation]) if params[:search][:designation].present?
    invitees = invitees.where(invitee_status: params[:search][:invitee_status]) if params[:search][:invitee_status].present?        
    invitees = invitees.where(visible_status: params[:search][:visible_status]) if params[:search][:visible_status].present?
    if params[:search][:login_status].present?
      ids = []
      invitees.each do |invitee|
        if  params[:search][:login_status] == "yes"  
          ids << invitee.id if invitee.analytics.where(:action => 'Login').present?
        else 
          ids << invitee.id if invitee.analytics.where(:action => 'Login').blank?
        end
      end
      invitees = invitees.where("id IN (?)",ids)  
    end  
    keyword = params[:search][:keyword]
      if params[:full_search].present?
        invitees = invitees.where("name_of_the_invitee like (?) or email like (?) or company_name like (?) or designation like (?) or mobile_no like (?)", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%", "%#{keyword}", "%#{keyword}")if keyword.present? and params[:full_search].present?
      else
        invitees = invitees.where("name_of_the_invitee like (?) or email like (?) or company_name like (?) or designation like (?)", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%", "%#{keyword}")if keyword.present?
      end
    invitees   
  end

  def get_badge_count
    b_count = self.badge_count + 1 rescue 1
    self.update_column(:badge_count, b_count)
    b_count
  end

  def generate_key
    self.key = Digest::SHA1.hexdigest(BCrypt::Engine.generate_salt)
    self.assign_secret_key
  end

  # def set_event_timezone
  #   event = self.event
  #   self.update_column("event_timezone", event.timezone)
  #   self.update_column("event_timezone_offset", event.timezone_offset)
  #   self.update_column("event_display_time_zone", event.display_time_zone)
  # end

  def assign_secret_key
    self.secret_key = self.get_secret_key
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = self.generate_authentication_token
    end
  end

  def get_secret_key
    Digest::SHA1.hexdigest(self.email.to_s + self.encrypted_password.to_s + self.key)
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless Invitee.where(authentication_token: token).first
    end
  end

  def encrypt_password
    if self.password.present?
      self.salt = BCrypt::Engine.generate_salt
      self.encrypted_password= BCrypt::Engine.hash_secret(password, salt)
    end
  end
  
  def clear_password
    self.password = nil
  end

  def get_event_id(mobile_app_code,submitted_app)
    event_status = (submitted_app == "Yes" ? ["published"] : ["approved","published"] )
    event_id = []
    mobile_app = MobileApplication.find_by_submitted_code(mobile_app_code)
    if mobile_app.present?
      events = mobile_app.events.where(:status => event_status)
      events.each do |event|
        event_id << event.id if event.invitees.pluck("lower(email)").include?(self.email.downcase)
      end if events.present?
    end
    event_id
  end

  def get_event_id_api(mobile_app_code,submitted_app,start_event_date,end_event_date)
    event_status = (submitted_app == "Yes" ? ["published"] : ["approved","published"] )
    event_id = []
    mobile_app = MobileApplication.find_by_submitted_code(mobile_app_code)
    if mobile_app.present?
      change_events = mobile_app.events.where(:status => event_status, :updated_at => start_event_date..end_event_date)
      if change_events.present?
        events = mobile_app.events.where(:status => event_status)
        events.each do |event|
          event_id << event.id if event.invitees.pluck("lower(email)").include?(self.email.downcase) #event.invitees.map{|n| n.email.downcase}.include?(self.email.downcase)
        end if events.present?
      end  
    end
    event_id
  end

  def update_event_updated_at
    self.event.update_column(:updated_at, Time.now) rescue nil
    self.event.theme.update_column(:updated_at, Time.now) rescue nil
  end

  def get_like(mobile_app_code,submitted_app)
    event_ids = get_event_id(mobile_app_code,submitted_app)
    user_ids = Invitee.where("event_id IN (?) and  email = ?",event_ids, self.email).pluck(:id) rescue nil
    conversation_ids = Conversation.where(:event_id => event_ids).pluck(:id) rescue nil
    data = []
    like = Like.where(:user_id => user_ids, :likable_id => conversation_ids , :likable_type => "Conversation") rescue []
    data = like.as_json() if like.present?
    data
  end
  
  def get_user_poll(mobile_app_code,submitted_app)
    event_ids = get_event_id(mobile_app_code,submitted_app)
    user_ids = Invitee.where("event_id IN (?) and  email = ?",event_ids, self.email).pluck(:id) rescue nil
    poll_ids = Poll.where(:event_id => event_ids).pluck(:id) rescue nil
    data = []
    user_poll = UserPoll.where(:user_id => user_ids, :poll_id => poll_ids) rescue []
    data = user_poll.as_json() if user_poll.present?
    data
  end

  def get_rating(mobile_app_code,submitted_app)
    event_ids = get_event_id(mobile_app_code,submitted_app)
    user_ids = Invitee.where("event_id IN (?) and  email = ?",event_ids, self.email).pluck(:id) rescue nil
    rating_ids = Agenda.where(:event_id => event_ids).pluck(:id) rescue nil
    rating_ids << Speaker.where(:event_id => event_ids).pluck(:id) rescue nil  
    data = []
    rating = Rating.where(:rated_by => user_ids, :ratable_id => rating_ids) rescue []
    data = rating.as_json() if rating.present?
    data
  end
  
  def get_user_feedback(mobile_app_code,submitted_app)
    event_ids = get_event_id(mobile_app_code,submitted_app)
    feedback_ids = Feedback.where(:event_id => event_ids).pluck(:id) rescue nil
    user_ids = Invitee.where("event_id IN (?) and  email = ?",event_ids, self.email).pluck(:id) rescue nil
    data = []
    user_feedback = UserFeedback.where(:user_id => user_ids, :feedback_id => feedback_ids) rescue []
    data = user_feedback.as_json(:methods => [:get_event_id]) if user_feedback.present?
    data
  end

  def get_user_quizzes(mobile_app_code,submitted_app)
    event_ids = get_event_id(mobile_app_code,submitted_app)
    quiz_ids = Quiz.where(:event_id => event_ids).pluck(:id) rescue nil
    user_ids = Invitee.where("event_id IN (?) and  email = ?",event_ids, self.email).pluck(:id) rescue nil
    data = []
    user_quiz = UserQuiz.where(:user_id => user_ids, :quiz_id => quiz_ids) rescue []
    data = user_quiz.as_json(:methods => [:get_event_id]) if user_quiz.present?
    data
  end

  def get_my_travels(mobile_app_code,submitted_app)
    event_ids = get_event_id(mobile_app_code,submitted_app)
    user_ids = Invitee.where("event_id IN (?) and  email = ?",event_ids, self.email).pluck(:id) rescue nil
    data = []
    my_travels = MyTravel.where(:invitee_id => user_ids, :event_id => event_ids) rescue []
    data = my_travels.as_json(:except => [:created_at, :updated_at, :attach_file_content_type, :attach_file_file_name, :attach_file_file_size, :attach_file_updated_at, :attach_file_2_file_name, :attach_file_2_content_type, :attach_file_2_file_size, :attach_file_2_updated_at, :attach_file_3_file_name, :attach_file_3_content_type, :attach_file_3_file_size, :attach_file_3_updated_at, :attach_file_4_file_name, :attach_file_4_content_type, :attach_file_4_file_size, :attach_file_4_updated_at, :attach_file_5_file_name, :attach_file_5_content_type, :attach_file_5_file_size, :attach_file_5_updated_at], :methods => [:attached_url,:attached_url_2,:attached_url_3,:attached_url_4,:attached_url_5, :attachment_type]) if my_travels.present?
    data
  end

  def get_analytics(mobile_app_code,submitted_app)
    event_ids = get_event_id(mobile_app_code,submitted_app)
    user_ids = Invitee.where("event_id IN (?) and  email = ?",event_ids, self.email).pluck(:id) rescue nil
    data = []
    analytics = Analytic.where("event_id IN (?) and viewable_type = ? and invitee_id IN (?) and viewable_id IS NOT NULL",event_ids, 'E-Kit', user_ids) rescue []
    data = analytics.as_json() if analytics.present?
    data
  end

  def get_my_profile(mobile_app_code,submitted_app)
    data = {}
    data[:current_user] = self.as_json(:only => [:designation,:id,:event_name,:name_of_the_invitee,:email,:company_name,:event_id,:about,:interested_topics,:country,:mobile_no,:website,:street,:locality,:location, :provider, :linkedin_id, :google_id, :twitter_id, :facebook_id, :points], :methods => [:qr_code_url,:profile_pic_url, :rank])
    data[:invitees] = get_all_mobile_app_users(mobile_app_code,submitted_app)
    data
  end
  
  def get_all_mobile_app_users(mobile_app_code,submitted_app)
    event_ids = get_event_id(mobile_app_code,submitted_app)
    invitees = Invitee.where("event_id IN (?) and  email = ?",event_ids, self.email) rescue nil
    invitees = invitees.as_json(:only => [:first_name, :last_name,:designation,:id,:event_name,:name_of_the_invitee,:email,:company_name,:event_id,:about,:interested_topics,:country,:mobile_no,:website,:street,:locality,:location, :invitee_status, :provider, :linkedin_id, :google_id, :twitter_id, :facebook_id, :points, :created_at, :updated_at], :methods => [:qr_code_url,:profile_pic_url, :rank, :feedback_last_updated_at, :feedback_last_updated_at_with_event_timezone, :created_at_with_event_timezone, :updated_at_with_event_timezone]) if invitees.present?
    invitees
  end

  def get_favorites(mobile_app_code,submitted_app)
    event_ids = get_event_id(mobile_app_code,submitted_app)
    invitees = Invitee.where("event_id IN (?) and  email = ?",event_ids, self.email).pluck(:id) rescue nil

    # favorite_ids = Favorite.where("invitee_id IN (?)", invitees).pluck(:id) rescue nil
    # favorite_types = Favorite.find(favorite_ids).map {|a| a.favoritable_type}

    # favorite_types.each do |favorite_type|
    #   if favorite_type == "Image"
      Favorite.where("invitee_id IN (?)", invitees).as_json(:only => [:id, :invitee_id , :favoritable_type, :favoritable_id, :event_id], :methods => [:image_url])
    #   else
    #     Favorite.where("invitee_id IN (?)", invitees).as_json(:only => [:id, :invitee_id , :favoritable_type, :favoritable_id, :event_id])
    #   end
    # end
  end

  # def get_favorites_gallery(mobile_app_code,submitted_app)
  #   mobile_application_ids = MobileApplication.where(submitted_code: mobile_app_code).pluck(:id)
  #   event_ids = Event.where(mobile_application_id: mobile_application_ids).pluck(:id)
  #   # event_ids = get_event_id(mobile_app_code,submitted_app)
  #   invitees = Invitee.where("event_id IN (?) and  email = ?",event_ids, self.email).pluck(:id) rescue nil
  #   binding.pry
  #   favorite_ids = Favorite.where("invitee_id IN (?)", invitees).pluck(:id) rescue nil
  #   favorite_ids = Favorite.find(favorite_ids).map {|a| a.favoritable_type}
  #   # Favorite.where("invitee_id IN (?)", invitees).as_json(:only => [:id, :invitee_id , :favoritable_type, :favoritable_id, :event_id]) rescue nil
  #   Image.where(:imageable_type => favorite_ids).as_json(:only => [:id, :imageable_type], :methods => [:image_url]) if favorite_ids.present?
  #   # Image.find(fav.favoratable_id) if fav.imageable_type == "Gallery"
  # end
   
  def get_my_network_users(mobile_app_code,submitted_app)
    event_ids = get_event_id(mobile_app_code,submitted_app)
    invitees = Invitee.where("event_id IN (?) and  email = ?",event_ids, self.email).pluck(:id) rescue nil
    ids = Favorite.where("invitee_id IN (?)", invitees).pluck(:favoritable_id)
    Invitee.where(:id => ids).as_json(:only => [:first_name, :last_name,:designation,:id,:event_name,:name_of_the_invitee,:email,:company_name,:event_id,:about,:interested_topics,:country,:mobile_no,:website,:street,:locality,:location, :provider, :linkedin_id, :google_id, :twitter_id, :facebook_id, :points], :methods => [:qr_code_url,:profile_pic_url]) rescue nil
  end

  def get_my_calender(mobile_app_code,submitted_app)
    event_ids = get_event_id(mobile_app_code,submitted_app)
    invitees = Invitee.where("event_id IN (?) and  email = ?",event_ids, self.email).pluck(:id) rescue nil
    Favorite.where("invitee_id IN (?) and favoritable_type = ?", invitees, "Agenda").as_json(:only => [:invitee_id , :favoritable_type, :favoritable_id, :event_id])
  end

  def set_status(invitee)
    if invitee== "active"
      self.active!
    elsif invitee== "deactive"
      self.deactive!
    end
  end
  
  def generate_qr_code
    # self.qr_code = QRCode.generate_qr_code(self.name_of_the_invitee, self.location, self.street, self.locality, self.country, self.mobile_no, self.email, self.website)
    if self.event.mobile_application.present? and self.qr_code.blank?
      self.qr_code = QRCode.generate_qr_code(self.event.mobile_application.id, self.id)
      self.save
    end
  end

  def update_favorite
    favorites = Favorite.where(favoritable_id: self.id, favoritable_type: "Invitee")
    favorites.update_all(updated_at: Time.now)  if favorites.present?
  end

  def rank
    count = 0
    invitees = Invitee.unscoped.where(:event_id => self.event_id, :visible_status => 'active').order('points desc') rescue nil
    if invitees.present?
      invitees.each do |inv|
        count += 1
        if inv.email == self.email
          break
        end
      end
    end
    count
  end

  def self.get_leaderboard_count(event)
    invitees = []
    invitees = Invitee.unscoped.where(:event_id => event.id, :visible_status => 'active').order('points desc').first(5)
    invitees.length
  end

  def self.social_media_data(provider,facebook_id,linkedin_id, google_id, twitter_id,user_email,first_name,last_name,event)
    if provider == "facebook"
      data = Invitee.facebook_data(provider,facebook_id, user_email, first_name, last_name, event)
    elsif provider == "linkedin"
      data = Invitee.linkedin_data(provider,linkedin_id, user_email, first_name, last_name, event)
    elsif (provider == "google+" || provider == "google ")
      data = Invitee.google_data(provider,google_id, user_email, first_name, last_name, event)
    elsif provider == "twitter"
      data = Invitee.twitter_data(provider,twitter_id, user_email, first_name, last_name, event)
    end
    data
  end

  def self.facebook_data(provider,facebook_id, user_email, first_name, last_name, event)
    if facebook_id.present?
      new_user = nil
      event.each do |e|
        user = e.invitees.where(:email => user_email) || user.where(:facebook_id => user_email)
        if user.present?
          if user.first.facebook_id.blank?
            user.first.update_column(:facebook_id, user_email)
            user.first.update_column(:provider, "facebook")
          end 
          user = user.first if user.present? 
        else
          pwd = Time.now.to_i.to_s
          user = e.invitees.new(:email => user_email, :facebook_id => user_email, :first_name => first_name, :last_name => last_name, :provider => "facebook", :password => pwd, :invitee_password => pwd)
          user.save
        end
        new_user = user
      end   
    end
    new_user
  end

  def self.linkedin_data(provider,linkedin_id, user_email, first_name, last_name, event)
    if linkedin_id.present?
      new_user = nil
      event.each do |e|
        user = e.invitees.where(:email => user_email) || user.where(:linkedin_id => user_email)
        if user.present?
          if user.first.linkedin_id.blank?
            user.first.update_column(:linkedin_id, user_email)
            user.first.update_column(:provider, "linkedin")
          end 
          user = user.first if user.present? 
        else
          pwd = Time.now.to_i.to_s
          user = e.invitees.new(:email => user_email, :linkedin_id => user_email, :first_name => first_name, :last_name => last_name, :provider => "linkedin", :password => pwd, :invitee_password => pwd)
          user.save
        end
        new_user = user
      end   
    end
    new_user
  end

  def self.google_data(provider,google_id, user_email, first_name, last_name, event)
    if google_id.present?
      new_user = nil
      event.each do |e|
        user = e.invitees.where(:email => user_email) || user.where(:google_id => user_email)
        if user.present?
          if user.first.google_id.blank?
            user.first.update_column(:google_id, user_email)
            user.first.update_column(:provider, "google+")
          end 
          user = user.first if user.present? 
        else
          pwd = Time.now.to_i.to_s
          user = e.invitees.new(:email => user_email, :google_id => user_email, :first_name => first_name, :last_name => last_name, :provider => "google+", :password => pwd, :invitee_password => pwd)
          user.save
        end
        new_user = user
      end   
    end
    new_user
  end

  def self.twitter_data(provider,twitter_id, user_email, first_name, last_name, event)
    if twitter_id.present?
      new_user = nil
      event.each do |e|
        user = e.invitees.where(:email => user_email) || user.where(:twitter_id => user_email)
        if user.present?
          if user.first.twitter_id.blank?
            user.first.update_column(:twitter_id, user_email)
            user.first.update_column(:provider, "twitter")
          end 
          user = user.first if user.present? 
        else
          pwd = Time.now.to_i.to_s
          user = e.invitees.new(:email => user_email, :twitter_id => user_email, :first_name => first_name, :last_name => last_name, :provider => "twitter", :password => pwd, :invitee_password => pwd)
          user.save
        end
        new_user = user
      end
    end
    new_user
  end

  def self.get_notification(notifications, event_ids, user, start_event_date, end_event_date)
    notification_ids = []
    notifications = notifications.where(:pushed => true) if notifications.present?
    notifications.each do |notification|
      invitee_notification_ids = InviteeNotification.where(:notification_id => notification.id).pluck(:invitee_id)
      if notification.group_ids.present?
        notification_ids << notification.id if user.present? and invitee_notification_ids.include? user.id#
      else
        notification_ids << notification.id
      end
    end
    notification_ids << get_read_notification_notification_ids(event_ids, user, start_event_date, end_event_date)
     notifications = Notification.where(:id => notification_ids.flatten).as_json(:except => [:group_ids, :sender_id, :status, :image_file_name, :image_content_type, :image_file_size, :image_updated_at], :methods => [:get_invitee_ids, :formatted_push_datetime_with_event_timezone])
    notifications.present? ? notifications : []
  end

  def get_notification(mobile_app_code, submitted_app)
    # event_ids = get_event_id(mobile_app_code,submitted_app)
    # notification_ids = []
    # notifications = Notification.where(:pushed => true, :event_id => event_ids).where('group_ids IS NOT NULL')
    # notifications.each do |notification|
    #   groups = InviteeGroup.where("id IN(?)", notification.group_ids)
    #   invitee_ids = []
    #   groups.map{|group| invitee_ids = invitee_ids + group.invitee_ids}  
    #     notification_ids << notification.id if invitee_ids.include? self.id.to_s
    # end
    # notifications = notifications.where(:id => notification_ids).as_json(:except => [:group_ids, :created_at, :updated_at, :sender_id, :status, :image_file_name, :ima$
    # notifications.present? ? notifications : []
    event_ids = get_event_id(mobile_app_code,submitted_app)
    user_ids = Invitee.where("event_id IN (?) and  email = ?",event_ids, self.email).pluck(:id) rescue nil
    data = []
    invitee_notifications = InviteeNotification.where(:event_id => event_ids, :invitee_id => user_ids) rescue nil
    notifications = Notification.where(:id => invitee_notifications.pluck(:notification_id))
    notifications.as_json(:except => [:group_ids, :sender_id, :status, :image_file_name, :image_content_type, :image_file_size, :image_updated_at, :open, :unread], :methods => [:get_invitee_ids, :formatted_push_datetime_with_event_timezone])
  end

  def get_read_notification(mobile_app_code,submitted_app)
    event_ids = get_event_id(mobile_app_code,submitted_app)
    user_ids = Invitee.where("event_id IN (?) and  email = ?",event_ids, self.email).pluck(:id) rescue nil
    data = []
    invitee_notifications = InviteeNotification.where(:event_id => event_ids, :invitee_id => user_ids) rescue nil
    data = invitee_notifications.as_json(:except => [:updated_at, :created_at]) if invitee_notifications.present?
    data
  end

  def self.get_read_notification(info, event_ids, user)
    user_ids = Invitee.where("event_id IN (?) and  email = ?",event_ids, user.email).pluck(:id) rescue nil
    data = []
    invitee_notifications = info.where(:invitee_id => user_ids) rescue nil
    data = invitee_notifications.as_json(:except => [:updated_at, :created_at]) if invitee_notifications.present?
    data
  end
  
  def self.get_read_notification_notification_ids(event_ids, user, start_event_date, end_event_date)
    start_event_date = start_event_date - 5.minutes
    info = InviteeNotification.where(:updated_at => start_event_date..end_event_date, event_id: event_ids)    
    user_ids = Invitee.where("event_id IN (?) and  email = ?",event_ids, user.email).pluck(:id) rescue nil
    invitee_notifications = info.where(:invitee_id => user_ids) rescue nil
    invitee_notifications.pluck(:notification_id) rescue []
  end

  def get_licensee_admin
    self.event.client.licensee rescue nil
  end

  def self.get_invitee_name(id)
    Invitee.find(id).name_of_the_invitee
  end
  def self.get_invitee_email(id)
    Invitee.find(id).email
  end

  def get_invitee_name
    self.name_of_the_invitee
  end

  def name_with_email
    user = "#{self.first_name.to_s + " " + self.last_name.to_s} (#{self.email})"
  end

  def created_at_with_event_timezone
    # self.created_at.in_time_zone(self.event_timezone)
    self.created_at + self.event.event_timezone_offset.to_i.seconds
  end
 
  def updated_at_with_event_timezone
    # self.updated_at.in_time_zone(self.event_timezone)
    self.updated_at + self.event.event_timezone_offset.to_i.seconds
  end

  private

  def downcase_email
    self.email = self.email.downcase if self.email.present?
  end
end
