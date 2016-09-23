class UserPoll < ActiveRecord::Base
	attr_accessor :platform
  belongs_to :poll
	belongs_to :user
  after_create :create_analytic_record
	validates :user_id,
              :presence => {:message=> "Not Found"}

	validates :poll_id,
              :presence => { :message=> "Not Found"}
	
	validates :answer,
              :presence => {:message=> "not matched"}

  validates_uniqueness_of :user_id, :scope => [:poll_id], :message => 'Poll already taken'

  after_save :update_poll, :update_last_updated_model

  default_scope { order('created_at desc') }

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end
	
  def update_poll
		Poll.find_by_id(self.poll_id).update_column(:updated_at, self.updated_at) rescue nil
	end

  def Timestamp
    self.created_at.in_time_zone(self.poll.event_timezone).strftime("%d/%m/%Y %T")
  end

  def email_id
    Invitee.find(self.user_id).email rescue nil
	end

  def name
    Invitee.find(self.user_id).name_of_the_invitee rescue nil  
  end

  def first_name
    Invitee.find(self.user_id).first_name rescue nil
  end

  def last_name
    Invitee.find(self.user_id).last_name rescue nil
  end

  def question
    self.poll.question if self.poll.present?
  end

  def user_answer
    answer_count = self.answer.split(',').count
    if answer_count == 1
      self.poll.attributes[self.answer.downcase]
    else
      self.answer.split(',').map{|value| self.poll.attributes[value]}.join(',')
    end
  end

  def create_analytic_record
    event_id = Invitee.find_by_id(self.user_id).event_id rescue nil
    analytic = Analytic.new(viewable_type: "Poll", viewable_id: self.poll_id, action: "poll answered", invitee_id: self.user_id, event_id: event_id, platform: platform)
    analytic.save rescue nil
  end

  def self.get_most_answered(count, event_id, from_date, to_date)
    poll_ids = Poll.where(:event_id => event_id).pluck(:id)
    user_polls = UserPoll.where('poll_id IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', poll_ids, from_date, to_date)
    user_polls.group(:poll_id).count.sort_by{|k, v| v}.last(count).reverse
  end

end
