class Faq < ActiveRecord::Base
      
  belongs_to :user
  belongs_to :event
  has_many :favorites, as: :favoritable, :dependent => :destroy

  validates :question, :answer,  presence: { :message => "This field is required." }
  #validates :sequence, uniqueness: {scope: :event_id}#, presence: true
  before_create :set_sequence_no
  after_create :set_dates_with_event_timezone

  default_scope { order("sequence") } 

  def self.search(params,faqs)
    keyword = params[:search][:keyword]
      faqs = faqs.where("question like ? or answer like ? or sequence like (?)", "%#{keyword}%","%#{keyword}%","%#{keyword}%")if keyword.present?
      faqs
  end 

  def set_dates_with_event_timezone
    event = self.event
    self.update_column("created_at_with_event_timezone", self.created_at.in_time_zone(event.timezone))
    self.update_column("updated_at_with_event_timezone", self.updated_at.in_time_zone(event.timezone))    
  end
  
  def set_sequence_no
    self.sequence = (Event.find(self.event_id).faqs.pluck(:sequence).compact.max.to_i + 1)rescue nil
  end


end
