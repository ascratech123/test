class Conversation < ActiveRecord::Base
  include AASM
  attr_accessor :platform
  @@auto_approve = nil
  belongs_to :event
  belongs_to :user
  belongs_to :user, :class_name => 'Invitee', :foreign_key => 'user_id'
  has_many :comments, as: :commentable, :dependent => :destroy
  has_many :likes, as: :likable, :dependent => :destroy
  has_many :favorites, as: :favoritable, :dependent => :destroy

  has_attached_file :image, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(CONVERSATION_IMAGE_PATH)
  
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"],:message => "please select valid format."
  validates :description, presence: { :message => "This field is required." }
  # validate :check_image_and_description
  validates :event_id, :user_id, presence: { :message => "This field is required." }

  after_create :set_status_as_per_auto_approve, :create_analytic_record, :set_event_timezone#, :set_dates_with_event_timezone
  after_save :update_last_updated_model

  scope :desc_ordered, -> { order('updated_at DESC') }
  scope :asc_ordered, -> { order('updated_at ASC') }

  aasm :column => :status do
    state :pending, :initial => true
    state :approved
    state :rejected
    
    event :approve do
      transitions :from => [:pending,:rejected], :to => [:approved]
    end 
    event :reject do
      transitions :from => [:pending,:approved], :to => [:rejected]
    end 
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def perform_conversation(conversation)
    if conversation == "approve"
      self.approve!
    elsif conversation == "pending"
      self.pending!
    elsif conversation == "reject"
      self.reject!
    end
  end
  
  def check_image_and_description
    if self.image.blank? and self.description.blank?
      self.error.add :description, 'You need to pass atleast one description or image'
    else
      return false
    end
  end

  def image_url(style=:large)
    url = style.present? ? self.image.url(style) : self.image.url
    url = "" if url == "/images/large/missing.png"
    url
  end

  def self.search(params,conversations)
    keyword = params[:search][:keyword]
    conversations = conversations.where("description like (?) ", "%#{keyword}%") if keyword.present?
    conversations
  end 

  def like_count
    Like.where(:likable_id => self.id, :likable_type => "Conversation").length rescue 0
  end
  
  def comment_count
    Comment.where(:commentable_id => self.id, :commentable_type => "Conversation").length rescue 0
  end

  def user_name
    Invitee.find_by_id(self.user_id).name_of_the_invitee rescue ""
  end

  def get_company_name
    Invitee.find_by_id(self.user_id).company_name rescue ""
  end

  def company_name
    Invitee.find_by_id(self.user_id).company_name rescue ""
  end

  def invitee_email
    Invitee.find_by_id(self.user_id).email rescue nil
  end

  def timestamp
    # self.created_at.in_time_zone(self.event_timezone).strftime('%m/%d/%Y %H:%M')
    (self.created_at + self.event_timezone_offset.to_i.seconds).strftime('%m/%d/%Y %H:%M')
  end

  # def likes
  #   likes = Like.where(:likable_id => self.id, :likable_type => "Conversation") rescue nil
  #   user_ids = likes.pluck(:user_id) rescue nil
  #   user_names = Invitee.where(:id => user_ids).pluck(:name_of_the_invitee) rescue nil
  #   user_names.join(",") rescue nil
  # end

  def user_comments
    comments = Comment.where(:commentable_id => self.id, :commentable_type => "Conversation")
    str = ""
    comments.each do |comment|
      user_name = Invitee.where(:id => comment.user_id).first.name_of_the_invitee rescue nil
      desc = comment.description if user_name.present?
      str += "#{user_name} => #{desc}" + ' ~ ' 
    end
    str
  end

  def set_status_as_per_auto_approve
    if Event.find(self.event_id).conversation_auto_approve == "true"
      self.update_column(:status, "approved") 
    elsif Event.find(self.event_id).conversation_auto_approve == "false"
      self.update_column(:status, "pending")
    end
  end

  def self.set_auto_approve(value,event)
    event.update_column(:conversation_auto_approve, value)
  end

  def create_analytic_record
    analytic = Analytic.new(viewable_type: "Conversation", viewable_id: self.id, action: "conversation post", invitee_id: self.user_id, event_id: self.event_id, platform: platform)
    analytic.save rescue nil
  end

  def set_event_timezone
    event = self.event
    self.update_column("event_timezone", event.timezone)
    self.update_column("event_timezone_offset", event.timezone_offset)
    self.update_column("event_display_time_zone", event.display_time_zone)
  end

  def set_dates_with_event_timezone
    event = self.event
    # self.update_column("created_at_with_event_timezone", self.created_at.in_time_zone(event.timezone))
    # self.update_column("updated_at_with_event_timezone", self.updated_at.in_time_zone(event.timezone))    
  end  

  def self.get_export_object(conversations)
    object = []
    conversation_without_comment = []
    comments = []
    conversations.each do |conversation|
      if conversation.comments.present?
        comments << conversation.comments
      else
        conversation_without_comment << conversation 
      end
    end if conversations.present?
    comment_obj = []
    # binding.pry
    comments.each do |comment|
      comment_obj << comment
    end if comments.present?
    object = object + comment_obj + conversation_without_comment
    object
  end

  def self.get_conversations_by_status(conversations, type)
    if type == "pending"
      conversations.where(:status => "pending")
    elsif type == "approved"
      conversations.where(:status => "approved")
    elsif type == "rejected"
      conversations.where(:status => "rejected")
    end
  end

  def conversation
    self.description.strip rescue ""
  end

  #use for conversation export remove blank values
  def commented_user_name
    ""
    # comment_by = self.comments.pluck(:user_id)
    # name_of_the_invitee = Invitee.find_by_id(comment_by).name_of_the_invitee
    # return name_of_the_invitee
    # binding.pry
  end

  def commented_user_email
    ""
    # comment_by = self.comments.pluck(:user_id)
    # email = Invitee.find_by_id(comment_by).email
    # return email
  end

  def email
    Invitee.find_by_id(self.user_id).email rescue ""
  end

  def name
    Invitee.find_by_id(self.user_id).name_of_the_invitee rescue ""
  end
  
  def first_name
    Invitee.find_by_id(self.user_id).first_name rescue ""
  end

  def profile_pic_url
    Invitee.find_by_id(self.user_id).profile_pic.url(:large) rescue ""
  end
  
  def last_name
    Invitee.find_by_id(self.user_id).last_name rescue ""
  end

  def comment
    ""
  end
  def Status
    self.status rescue ""
  end

  def post_id
    self.id
  end

  def created_at_with_event_timezone
    # self.created_at.in_time_zone(self.event_timezone)
    self.created_at + self.event_timezone_offset.to_i.seconds
  end

  def updated_at_with_event_timezone
    # self.updated_at.in_time_zone(self.event_timezone)
    self.updated_at + self.event_timezone_offset.to_i.seconds
  end

  def formatted_created_at_with_event_timezone
    # self.created_at_with_event_timezone.strftime("%b %d at %I:%M %p (GMT %:z)")
    # created_at_with_tmz = self.created_at_with_event_timezone.strftime("%Y %b %d at %l:%M %p (GMT %:z)")
    created_at_with_tmz = self.created_at_with_event_timezone.strftime("%Y %b %d at %l:%M %p (#{self.event_display_time_zone})")
    year = Time.now.strftime("%Y") + " "
    created_at_with_tmz.sub(year, "")
  end

  def formatted_updated_at_with_event_timezone
    # self.updated_at_with_event_timezone.strftime("%b %d at %I:%M %p (GMT %:z)")
    # updated_at_with_tmz = self.updated_at_with_event_timezone.strftime("%Y %b %d at %l:%M %p (#{self.event.display_time_zone})")
    updated_at_with_tmz = self.updated_at_with_event_timezone.strftime("%Y %b %d at %l:%M %p (#{self.event_display_time_zone})")
    year = Time.now.strftime("%Y") + " "
    updated_at_with_tmz.sub(year, "")    
  end

  def self.get_approved_conversation(id)
    self.where("id = ? and status = ?", id, "approved").first
  end
end