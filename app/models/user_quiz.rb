class UserQuiz < ActiveRecord::Base
	attr_accessor :platform
  belongs_to :quiz
	belongs_to :user
  after_create :create_analytic_record
	validates :user_id,
              :presence => {:message=> "Not Found"}

	validates :quiz_id,
              :presence => { :message=> "Not Found"}
	
	validates :answer,
              :presence => {:message=> "not matched"}

	validates_uniqueness_of :user_id, :scope => [:quiz_id], :message => 'Quiz already answered'

  after_save :update_quiz

  default_scope { order('created_at desc') }

	def update_quiz
		quiz = Quiz.find_by_id(self.quiz_id)
                quiz.update_column(:updated_at, self.updated_at) rescue nil
                quiz.update_last_updated_model
	end

  def email
    event = self.quiz.event
    invitee = event.invitees.where(:id => self.user_id).first
    invitee.email rescue nil
	end

  def email_id
    event = self.quiz.event
    invitee = event.invitees.where(:id => self.user_id).first
    invitee.email rescue nil
  end

  def first_name
    Invitee.find(self.user_id).first_name rescue nil
  end

  def last_name
    Invitee.find(self.user_id).last_name rescue nil
  end

  def Timestamp
    # self.created_at.in_time_zone(self.quiz.event.time_zone).strftime("%d/%m/%Y %T")
    (self.created_at + self.quiz.event.timezone_offset.to_i.seconds).strftime("%d/%m/%Y %T")
  end
  
  def question
    self.quiz.question if self.quiz.present?
  end


  def user_answer
    self.answer#.join(', ').to_s
    #self.quiz.attributes[self.answer.downcase]
  end
  
  # def answer
  #   self.quiz.correct_answer
  # end

  def correct_answer
    self.quiz.correct_answer.join(', ').to_s
  end 

  def get_event_id
    self.quiz.event_id rescue nil
  end
  
  def create_analytic_record
    event_id = Invitee.find_by_id(self.user_id).event_id rescue nil
    analytic = Analytic.new(viewable_type: "Quiz", viewable_id: self.quiz_id, action: "played", invitee_id: self.user_id, event_id: event_id, platform: platform)
    analytic.points = self.quiz.correct_answer.include?(self.answer) ? 5 : 2
    analytic.save rescue nil
  end

  def self.get_most_answered(count, event_id, from_date, to_date)
    quiz_ids = Quiz.where(:event_id => event_id).pluck(:id)
    user_quizzes = UserQuiz.where('quiz_id IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', quiz_ids, from_date, to_date)
    user_quizzes.group(:quiz_id).count.sort_by{|k, v| v}.last(count).reverse
  end

end
