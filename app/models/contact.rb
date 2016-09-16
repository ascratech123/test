class Contact < ActiveRecord::Base
	belongs_to :event
	validates :email,:event_id, presence: { :message => "This field is required." }
  after_save :update_last_updated_model
  
	default_scope { order('created_at desc') }

  def self.update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end
end
