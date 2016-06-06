class Contact < ActiveRecord::Base
	belongs_to :event
	validates :email,:event_id, presence: { :message => "This field is required." }
	default_scope { order('created_at desc') }
end
