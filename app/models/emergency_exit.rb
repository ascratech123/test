class EmergencyExit < ActiveRecord::Base
  belongs_to :event
  has_attached_file :emergency_exit,{}.merge(Emergency_Exit_IMAGE_PATH)
  has_attached_file :icon, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(Emergency_Exit_icon_IMAGE_PATH)

  validates_attachment_content_type :emergency_exit, :content_type => ['application/pdf', 'application/msword', 'text/plain',"image/jpg", "image/jpeg", "image/png"],:message => "please select valid format."
  validates_attachment_content_type :icon, :content_type => ["image/png"],:message => "please select valid format."
  validates_attachment_presence :emergency_exit,:message => "This field is required."
  validates :title, presence: { :message => "This field is required." } 
  validate :image_dimensions

  before_save :update_event_name
  after_save :update_last_updated_model
  
  default_scope { order('created_at desc') }

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def update_event_name
  	self.event_name = Event.find_by_id(self.event_id).event_name rescue nil
  end

  def emergency_exit_url
  	self.emergency_exit.url
  end
  def icon_url
    self.icon.url
  end

  def attachment_type
    file_type = self.emergency_exit_content_type.split("/").last rescue ""
    file_type
  end

   def image_dimensions
    if self.icon_file_name_changed?  
      icon_dimension_height  = 288.0
      icon_dimension_width = 288.0
      dimensions = Paperclip::Geometry.from_file(icon.queued_for_write[:original].path)
      if (dimensions.width != icon_dimension_width or dimensions.height != icon_dimension_height)
        errors.add(:icon, "Icon size should be 288x288px only")
      else
        self.errors.delete(:icon)
      end
    end
  end
  
end