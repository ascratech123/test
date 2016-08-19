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

  after_create :set_status_as_per_auto_approve, :create_analytic_record, :set_event_timezone

  default_scope { order('created_at desc') }

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
    self.created_at.in_time_zone('Kolkata').strftime('%m/%d/%Y %H:%M')
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
    self.update_column("event_timezone", self.event.timezone.capitalize)
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
    comments.each do |comment|
      comment_obj << comment[0]
    end
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
  end
  def commented_user_email
    ""
  end
  def email
    Invitee.find_by_id(self.user_id).email rescue ""
  end

  def name
    Invitee.find_by_id(self.user_id).name_of_the_invitee rescue ""
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

  def created_at_with_timezone
    self.created_at.in_time_zone(self.event_timezone.capitalize)
  end

  def updated_at_with_timezone
    self.updated_at.in_time_zone(self.event_timezone.capitalize)
  end
end