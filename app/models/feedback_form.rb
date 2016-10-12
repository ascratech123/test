class FeedbackForm < ActiveRecord::Base
	belongs_to :event
	has_many :feedbacks

	validates :title, presence: { :message => "This field is required." }

	after_save :update_last_updated_model

	def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end
end
