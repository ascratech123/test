class Poll < ActiveRecord::Base
  
  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am, :end_time_hour, :end_time_minute ,:end_time_am

  belongs_to :event
  has_many :user_polls, :dependent => :destroy
  has_many :favorites, as: :favoritable, :dependent => :destroy
  
  validates :option_type,  presence: { :message => "This field is required." }, unless: Proc.new { |object| object.description == true }
  validates :question, presence: { :message => "This field is required." }
  validates :option1, :option2, presence: { :message => "This field is required." }, if: Proc.new { |object| object.option_type == "Radio" || object.option_type == "Checkbox"}
  
  before_save :set_time
  after_save :push_notification, :check_push_to_wall_status
  before_create :set_sequence_no
  after_create :set_status#, :set_status_as_per_auto_approve

  default_scope { order("sequence") }

  include AASM
  aasm :column => :status do  # defaults to aasm_state
    state :activate, :initial => true
    state :deactivate
    
    event :activate do
      transitions :from => [:deactivate], :to => [:activate]
    end 
    event :deactivate do
      transitions :from => [:activate], :to => [:deactivate]
    end
  end

  def set_status
    if self.status.blank?
      self.status = "activate"
      self.save
    end
  end

  def self.search(params,polls)
    keyword = params[:search][:keyword]
     polls = polls.where("question like (?) ", "%#{keyword}%") if keyword.present?
  end   

  def push_notification
    if self.status == 'approved' and self.status_changed?
      client = self.event.client
      licensee_user = User.find(client.licensee_id) rescue nil
      if licensee_user.present?
        users = licensee_user.get_licensee_users
        users.each do |u|
          u.push_notifications("New polls for you", 'Poll', self.id)
        end
      end
    end
  end
  
  def check_push_to_wall_status
    if self.status == "deactivate"
      self.update_column(:on_wall, "no")
    end
  end
  
  def option_percentage
    data = {}
    option1=option2=option3=option4=option5=option6=0
    data["total"] = self.user_polls.count
    self.user_polls.each do |user_poll|
      option1 = user_poll.answer.downcase.include?("option1") ? option1 + 1 : option1 rescue option1
      option2 = user_poll.answer.downcase.include?("option2") ? option2 + 1 : option2 rescue option2
      option3 = user_poll.answer.downcase.include?("option3") ? option3 + 1 : option3 rescue option3
      option4 = user_poll.answer.downcase.include?("option4") ? option4 + 1 : option4 rescue option4
      option5 = user_poll.answer.downcase.include?("option5") ? option5 + 1 : option5 rescue option5
      option6 = user_poll.answer.downcase.include?("option6") ? option6 + 1 : option6 rescue option6
    end
    data["option1"] = option1 rescue nil
    data["option2"] = option2 rescue nil
    data["option3"] = option3 rescue nil 
    data["option4"] = option4 rescue nil
    data["option5"] = option5 rescue nil
    data["option6"] = option6 rescue nil
    data
  end

  def change_status(poll)
    if poll == "activate"
      self.activate!
    elsif poll == "deactivate"
      self.deactivate!
    end
  end

  def set_sequence_no
    self.sequence = (Event.find(self.event_id).polls.pluck(:sequence).compact.max.to_i + 1)rescue nil
  end

  def set_time
    start_date = self.poll_start_date_time.nil? ? Time.now : self.poll_start_date_time
    end_date = self.poll_end_date_time.nil? ? Time.now : self.poll_end_date_time
    start_date_time = "#{start_date.strftime('%d/%m/%Y')} #{self.start_time_hour.gsub(':', "") rescue nil}:#{self.start_time_minute.gsub(':', "") rescue nil}:#{0} #{self.start_time_am}"
    end_date_time = "#{end_date.strftime('%d/%m/%Y')} #{self.end_time_hour.gsub(':', "") rescue nil}:#{self.end_time_minute.gsub(':', "") rescue nil}:#{0} #{self.end_time_am}"
    self.poll_start_date_time = start_date_time.to_time rescue nil
    self.poll_end_date_time = end_date_time.to_time rescue nil
  end

  def time_format
    if (self.start_time_hour.blank? or self.start_time_minute.blank? or self.start_time_am.blank?)
      errors.add(:start_time_hour, "can't be blank")
    end

    if (self.start_time_hour.blank? or self.start_time_minute.blank? or self.start_time_am.blank?)
      errors.add(:start_time_hour, "can't be blank")
    end
  end

  # def set_status_as_per_auto_approve
  #   if Event.find(self.event_id).poll_auto_approve == "true"
  #     self.update_column(:status, "activate") 
  #   elsif Event.find(self.event_id).poll_auto_approve == "false"
  #     self.update_column(:status, "deactivate")
  #   end
  # end

  # def self.set_auto_approve(value,event)
  #   event.update_column(:poll_auto_approve, value)
  # end
  
end
