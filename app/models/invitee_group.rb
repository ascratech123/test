class InviteeGroup < ActiveRecord::Base
	belongs_to :event
	serialize :invitee_ids, Array
	validates :name, :invitee_ids, presence:{ :message => "This field is required." }
	
	def get_invitee_name
    names = ""
    names = Invitee.where("id IN(?)",self.invitee_ids).map {|i| i.name_of_the_invitee} rescue nil if self.invitee_ids.present?
    names.join(",")
  end

end
