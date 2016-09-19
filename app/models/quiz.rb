class Quiz < ActiveRecord::Base
  attr_accessor :correct_ans_option1,:correct_ans_option2,:correct_ans_option3,:correct_ans_option4,:correct_ans_option5
  serialize :correct_answer, Array

  belongs_to :event
  has_many :user_quizzes, :dependent => :destroy
  has_many :favorites, as: :favoritable, :dependent => :destroy
  
  validates :correct_answer,:question,:option1,:option2, presence: { :message => "This field is required." }
  
  before_validation :set_correct_answer, :if => Proc.new{|p| p.correct_ans_option1.present? or p.correct_ans_option2.present? or p.correct_ans_option3.present? or p.correct_ans_option4.present? or p.correct_ans_option5.present?} 
  before_create :set_sequence_no
  after_create :set_event_timezone
  after_save :push_notification, :update_last_updated_model

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

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def correct_ans_option1=(var)
    @correct_ans_option1 = var
  end

  def correct_ans_option1
    @correct_ans_option1
  end

  def self.search(params,quizzes)
    keyword = params[:search][:keyword]
     quizzes = quizzes.where("question like (?) ", "%#{keyword}%") if keyword.present?
  end   

  def push_notification
    if self.status == 'approved' and self.status_changed?
      client = self.event.client
      licensee_user = User.find(client.licensee_id) rescue nil
      if licensee_user.present?
        users = licensee_user.get_licensee_users
        users.each do |u|
          u.push_notifications("New quizzes for you", 'Quizze', self.id)
        end
      end
    end
  end
  
  def change_status(quizze)
    if quizze == "activate"
      self.activate!
    elsif quizze == "deactivate"
      self.deactivate!
    end
  end

  def set_sequence_no
    self.sequence = (Event.find(self.event_id).quizzes.pluck(:sequence).compact.max.to_i + 1)rescue nil
  end

  def set_correct_answer
    self.correct_answer = self.correct_answer.compact
    set_ans = []
    set_ans <<  (self.option1.present? ? self.option1 : nil) if self.correct_ans_option1.present?
    set_ans << (self.option2.present? ? self.option2 : nil) if self.correct_ans_option2.present? 
    set_ans << (self.option3.present? ? self.option3 : nil) if self.correct_ans_option3.present?
    set_ans << (self.option4.present? ? self.option4 : nil) if self.correct_ans_option4.present?
    set_ans << (self.option5.present? ? self.option5 : nil) if self.correct_ans_option5.present?
    self.correct_answer = set_ans.compact
  end

  def get_correct_answer_percentage
    correct_percentage = 0
    count = 0
    total_ans = self.user_quizzes
    length = total_ans.length rescue 0
    total_ans.each do |ans|
      count = count + 1 if self.correct_answer.include?(ans.answer)
    end
    if length != 0 and count != 0
      correct_percentage = (count/length.to_f) * 100
    end
    correct_percentage
  end

  def get_total_answer
    self.user_quizzes.length rescue 0
  end

  def get_correct_answer_count
    count = 0
    total_ans = self.user_quizzes
    total_ans.each do |ans|
      count = count + 1 if self.correct_answer.include?(ans.answer)
    end
    count
  end

  def set_event_timezone
    self.update_column(:event_timezone, self.event.timezone)
  end

end