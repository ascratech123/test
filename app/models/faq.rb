class Faq < ActiveRecord::Base
      
  belongs_to :user
  belongs_to :event
  has_many :favorites, as: :favoritable, :dependent => :destroy

  validates :question, :answer,  presence: { :message => "This field is required." }
  #validates :sequence, uniqueness: {scope: :event_id}#, presence: true
  before_create :set_sequence_no
  after_create :set_event_timezone
  after_save :update_last_updated_model

  default_scope { order("sequence") } 

  def self.search(params,faqs)
    keyword = params[:search][:keyword]
      faqs = faqs.where("question like ? or answer like ? or sequence like (?)", "%#{keyword}%","%#{keyword}%","%#{keyword}%")if keyword.present?
      faqs
  end 
  
  def set_sequence_no
    self.sequence = (Event.find(self.event_id).faqs.pluck(:sequence).compact.max.to_i + 1)rescue nil
  end

  def set_event_timezone
    self.update_column("event_timezone", self.event.timezone)
  end
  
  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

end
