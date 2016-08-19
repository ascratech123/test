class VenueSection < ActiveRecord::Base
   belongs_to :event
   has_many :invitees

  #  def test
  #   VenueSection.where(:event_id => self.event_id,:default_access => "no").pluck(:name).join(',') rescue nil
  # end
  
  # def method_missing method_name, *args
  #   attr_key = self.attributes.except('id', 'created_at', 'updated_at', 'event_id').map{|k, v| v.to_s.length > 0 && v.downcase != "yes" ? v.downcase : nil}.compact!
  #   # attr_value = self.invitee_datum.first.attributes[attr_key.first.to_s] rescue nil
  #   attr_value
  # end
end
