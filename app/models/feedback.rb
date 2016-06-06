class Feedback < ActiveRecord::Base
  
  belongs_to :event
  has_many :user_feedbacks
  has_many :favorites, as: :favoritable, :dependent => :destroy

  validates :question, presence: { :message => "This field is required." }
  validates :option_type,  presence: { :message => "This field is required." }, unless: Proc.new { |object| object.description == true }
  validates :option1, :option2, presence: { :message => "This field is required." }, if: Proc.new { |object| object.option_type == "Radio" || object.option_type == "Checkbox"}

  before_create :set_sequence_no
  after_create :set_description_value 

  default_scope { order("sequence") }

  def self.search(params,feedbacks)
    keyword = params[:search][:keyword]
    feedbacks = feedbacks.where("question like (?) ", "%#{keyword}%") if keyword.present?
    feedbacks
  end 

  def set_sequence_no
    self.sequence = (Event.find(self.event_id).feedbacks.pluck(:sequence).compact.max.to_i + 1)rescue nil
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

end