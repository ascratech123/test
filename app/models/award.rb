class Award < ActiveRecord::Base
  
  belongs_to :event
  has_many :winners, :dependent => :destroy

  validates :title,presence: { :message => "This field is required." }
  
  before_create :set_sequence_no

  default_scope { order("sequence") }
  
  def self.search(params, awards)
    keyword = params[:search][:keyword]
    awards = awards.where("title like ?", "%#{keyword}%") if keyword.present?
    awards
  end

  def set_sequence_no
    self.sequence = (Event.find(self.event_id).awards.pluck(:sequence).compact.max.to_i + 1) rescue nil
  end
end