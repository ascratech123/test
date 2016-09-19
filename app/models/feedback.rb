class Feedback < ActiveRecord::Base
  
  belongs_to :event
  has_many :user_feedbacks
  has_many :favorites, as: :favoritable, :dependent => :destroy

  validates :question, presence: { :message => "This field is required." }
  validates :option_type,  presence: { :message => "This field is required." }, unless: Proc.new { |object| object.description == true }
  validates :option1, :option2, presence: { :message => "This field is required." }, if: Proc.new { |object| object.option_type == "Radio" || object.option_type == "Checkbox"}

  before_create :set_sequence_no
  after_create :set_description_value, :set_event_timezone
  after_save :update_last_updated_model

  default_scope { order("sequence") }

  def self.search(params,feedbacks)
    keyword = params[:search][:keyword]
    feedbacks = feedbacks.where("question like (?) ", "%#{keyword}%") if keyword.present?
    feedbacks
  end 

  def set_sequence_no
    self.sequence = (Event.find(self.event_id).feedbacks.pluck(:sequence).compact.max.to_i + 1)rescue nil
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  # def option_percentage(option_name='option1')
  #   percentage, count = 0, 0
  #   user_feedbacks = self.user_feedbacks
  #   total = self.user_feedbacks.count
  #   user_feedbacks.each do |ans|
  #     count = count + 1 if ans.answer.split(",").include? "option1"
  #     percentage = (count.to_f/total) * 100 rescue 0
  #   end
  #   return "#{percentage.to_i} %" 
  # end

  def set_description_value
    if self.option_type == "Textbox"
      self.description = true
      self.save
    end
  end

  def set_event_timezone
    self.update_column(:event_timezone, self.event.timezone)
  end

  def created_at_with_event_timezone
    self.created_at.in_time_zone(self.event_timezone)
  end

  def updated_at_with_event_timezone
    self.updated_at.in_time_zone(self.event_timezone)
  end

end