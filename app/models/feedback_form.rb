class FeedbackForm < ActiveRecord::Base
	belongs_to :event 
	has_many :feedbacks, :dependent => :destroy

	validates :title, presence: { :message => "This field is required." }

	validates :title, uniqueness: {scope: :event_id, :case_sensitive => false}

	after_save :update_last_updated_model
	before_create :set_sequence_no

        default_scope { order("sequence") }

	def set_sequence_no
    self.sequence = (Event.find(self.event_id).feedback_forms.pluck(:sequence).compact.max.to_i + 1)rescue nil
  end

	def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end 
end