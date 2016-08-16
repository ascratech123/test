class InviteeAccess < ActiveRecord::Base
  belongs_to :venue_section
  belongs_to :invitee


  # def VenueSections
  #   VenueSection.where(:event_id => @event.id,:default_access => "no").pluck(:name) rescue nil
  # end
end
