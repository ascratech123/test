class UserFeedback < ActiveRecord::Base
  attr_accessor :platform

  belongs_to :feedback
  belongs_to :user

  validates :user_id, :feedback_id, presence: true
  validates_uniqueness_of :user_id, :scope => [:feedback_id], :message => 'Feedback already submitted'
  validate :check_answer_or_description_present
  after_create :create_analytic_record
  default_scope { order('created_at desc') }
  
  def get_event_id
    self.feedback.event_id rescue nil
  end

  def Timestamp
    self.feedback.created_at.in_time_zone('Kolkata').strftime('%m/%d/%Y %T') rescue ""
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
    correct_answer = self.answer.downcase if correct_answer.blank? and self.answer.downcase.present?
    correct_answer.to_s
    # self.answer.downcase rescue ""
  end

  def Description
    self.description rescue ""
  end
  def Timestamp
    self.created_at.in_time_zone('Kolkata').strftime("%d/%m/%Y %T")
  end
  def create_analytic_record
    event_id = Invitee.find_by_id(self.user_id).event_id rescue nil
    if Analytic.where(viewable_type: "Feedback", action: "feedback given", invitee_id: self.user_id, event_id: event_id).blank?
      analytic = Analytic.new(viewable_type: "Feedback", viewable_id: self.feedback_id, action: "feedback given", invitee_id: self.user_id, event_id: event_id, platform: platform)
      analytic.save rescue nil
    end
  end

  def created_at_with_event_timezone
    self.created_at.in_time_zone(self.feedback.event_timezone.capitalize)
  end

  def updated_at_with_event_timezone
    self.updated_at.in_time_zone(self.feedback.event_timezone.capitalize)
  end

  def check_answer_or_description_present
    if self.answer.blank? and self.description.blank?
      errors.add(:answer, "This field is required.") if self.answer.blank?
      errors.add(:description, "This field is required.") if self.description.blank?
    end
  end
end
