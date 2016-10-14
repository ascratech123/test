class UserFeedback < ActiveRecord::Base
  attr_accessor :platform

  belongs_to :feedback
  belongs_to :user
  after_save :update_invitee_updated_at

  validates :user_id, :feedback_id, presence: true
  validates_uniqueness_of :user_id, :scope => [:feedback_id], :message => 'Feedback already submitted'
  validate :check_answer_or_description_present
  after_create :create_analytic_record
  default_scope { order('created_at desc') }

  def update_invitee_updated_at
    invitee = Invitee.find_by_id(self.user_id) if self.user_id.present?
    if invitee.present?
      invitee.updated_at = self.updated_at
      invitee.save
    end
  end

  def feedback_form_id
    self.feedback.feedback_form_id.present? ? self.feedback.feedback_form_id : ""
  end  

  def get_event_id
    self.feedback.event_id rescue nil
  end
  
  def Timestamp
    feedback = self.feedback
    # feedback.created_at.in_time_zone(feedback.event_timezone).strftime('%m/%d/%Y %T') rescue ""
    (feedback.created_at + feedback.event.timezone_offset.to_i.seconds).strftime("%d/%m/%Y %T")
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

  def last_name
    Invitee.find_by_id(self.user_id).last_name rescue ""
  end

	def Question
		self.feedback.question rescue ""
	end

	def user_answer
    correct_answer = ""
    correct_answer = self.feedback.attributes[self.answer.downcase] rescue ""
    if correct_answer.blank? and self.answer.downcase.present?
      # correct_answer = Feedback.find_by_id(self.feedback_id)
      # binding.pry 
      # correct_answer = correct_answer.option1 + "," + correct_answer.option2 +  "," + correct_answer.option3 + "," + correct_answer.option4 + "," + correct_answer.option5 + "," + correct_answer.option6 + "," + correct_answer.option7 + "," + correct_answer.option8 + "," + correct_answer.option9 + "," + correct_answer.option10
      # correct_answer = self.answer.downcase 
      values = self.answer.split(',')
      correct_answer = values.map{|value| self.feedback.attributes[value]}.join(',')
      # correct_answer = correct_answer.split(',').join(',')
      # correct_answer = correct_answer.map {|x| x[/\d+/]}.join(',')
    end
    correct_answer.to_s
    # self.answer.downcase rescue ""
  end

  def Description
    self.description rescue ""
  end

  def create_analytic_record
    event_id = Invitee.find_by_id(self.user_id).event_id rescue nil
    if Analytic.where(viewable_type: "Feedback", action: "feedback given", invitee_id: self.user_id, event_id: event_id).blank?
      analytic = Analytic.new(viewable_type: "Feedback", viewable_id: self.feedback_id, action: "feedback given", invitee_id: self.user_id, event_id: event_id, platform: platform)
      analytic.save rescue nil
    end
  end

  def check_answer_or_description_present
    if self.answer.blank? and self.description.blank?
      errors.add(:answer, "This field is required.") if self.answer.blank?
      errors.add(:description, "This field is required.") if self.description.blank?
    end
  end
end
