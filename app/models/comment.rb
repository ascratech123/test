class Comment < ActiveRecord::Base
  
  attr_accessor :platform
  belongs_to :commentable, polymorphic: true
  belongs_to :user, :class_name => 'Invitee', :foreign_key => 'user_id'
  
  validates :description,:commentable_id,:commentable_type,:user_id,:presence =>true
  
  after_create :create_analytic_record
  after_save :update_conversation

  default_scope { order('created_at desc') }
  
  def commented_user_name
    # Invitee.find_by_id(self.user_id).name_of_the_invitee rescue ""
    self.user.name_of_the_invitee rescue ""
  end

  def update_conversation
    Conversation.find_by_id(self.commentable_id).update_column(:updated_at, self.updated_at) rescue nil
  end

  def self.get_comments(conversations, start_event_date, end_event_date)
    data = []
    conversations.each do |conversation|
      data << Comment.where(:commentable_id => conversation.id, :commentable_type => "Conversation", :updated_at =>  start_event_date..end_event_date).limit(5)
    end
    data.flatten!
  end

  def commented_user_email
    self.user.email rescue ""
  end

  def email
    # self.user.email rescue ""
    # binding.pry 
    user_id = Conversation.find_by_id(self.commentable_id).user_id
    email = Invitee.find_by_id(user_id).email rescue ""
    return email
  end

  def user_name
    self.user.name_of_the_invitee rescue nil
  end

  def name
    self.user.name_of_the_invitee rescue ""
  end

  def first_name
    # Invitee.find_by_id(self.user_id).first_name rescue ""
    user_id = Conversation.find_by_id(self.commentable_id).user_id
    first_name = Invitee.find_by_id(user_id).first_name rescue ""
    return first_name
  end
  
  def last_name
    user_id = Conversation.find_by_id(self.commentable_id).user_id
    last_name = Invitee.find_by_id(user_id).last_name rescue ""
    return last_name
    # Invitee.find_by_id(self.user_id).last_name rescue ""
  end
  
  def conversation
    conversation = self.commentable.description
    return conversation.gsub(/[\r\n]/, '')
  end

  def comment
    self.description
  end

  def like_count
    Like.where(:likable_id => self.commentable_id, :likable_type => "Conversation").length rescue 0
  end
  
  def timestamp
    self.commentable.created_at.in_time_zone('Kolkata').strftime('%m/%d/%Y %H:%M') rescue ""
  end
  def image_url
    conversation = Conversation.find_by_id(self.commentable_id)
    url = conversation.present? ? conversation.image.url(:large) : conversation.image.url
    url = "" if url == "/images/large/missing.png"
    url
  end
  
  def create_analytic_record
    event_id = Invitee.find_by_id(self.user_id).event_id rescue nil
    analytic = Analytic.new(viewable_type: self.commentable_type, viewable_id: self.commentable_id, action: "comment", invitee_id: self.user_id, event_id: event_id, platform: platform)
    analytic.save rescue nil
  end

  def self.get_top_commented(count, type, event_id, from_date, to_date)
    conversation_ids = Conversation.where(:event_id => event_id).pluck(:id)
    comments = Comment.where('commentable_type = ? and commentable_id IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', type, conversation_ids, from_date, to_date)
    comments.group(:commentable_id).count.sort_by{|k, v| v}.last(count).reverse
  end

  def post_id
    self.commentable.id
  end

  def Status
    self.commentable.status rescue ""
  end

  def created_at_with_event_timezone
    timezone = Conversation.joins(:event).select("conversations.id as conversation_id, events.id as event_id, events.timezone as timezone").where("conversations.id = ?", self.commentable_id).first.timezone
    self.created_at.in_time_zone(timezone)
  end

  def updated_at_with_event_timezone
    timezone = Conversation.joins(:event).select("conversations.id as conversation_id, events.id as event_id, events.timezone as timezone").where("conversations.id = ?", self.commentable_id).first.timezone
    self.updated_at.in_time_zone(timezone)
  end

  def formatted_created_at_with_event_timezone
    self.created_at_with_event_timezone.strftime("%b %d at %H:%M %p (GMT %:z)")
  end

  def formatted_updated_at_with_event_timezone
    self.updated_at_with_event_timezone.strftime("%b %d at %H:%M %p (GMT %:z)")
  end

end

