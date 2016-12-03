class Contact < ActiveRecord::Base
	belongs_to :event
	validates :event_id, presence: { :message => "This field is required." }
  validates :email,
            :format => {
              :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
              :message => "Sorry, this doesn't look like a valid email." }
  after_save :update_last_updated_model
  
	default_scope { order('created_at desc') }

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end
end
