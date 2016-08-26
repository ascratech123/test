class HighlightImage < ActiveRecord::Base

  belongs_to :event                                       

  has_attached_file :highlight_image, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(HIGHLIGHT_IMAGE_PATH)
  
  validates_attachment_content_type :highlight_image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"],:message => "please select valid format."
  after_create :set_dates_with_event_timezone

  def set_dates_with_event_timezone	
    event = self.event
    self.update_column("created_at_with_event_timezone", self.created_at.in_time_zone(event.timezone))
    self.update_column("updated_at_with_event_timezone", self.updated_at.in_time_zone(event.timezone))    
  end

  def highlight_image_url(style=:large)
  	style.present? ? self.highlight_image.url(style) : self.highlight_image.url
	end

  def to_jq_upload
    {
      "name" => read_attribute(:highlight_image),
      "size" => highlight_image.size,
      "url" => highlight_image.url(:thumb),
      "thumbnail_url" => highlight_image.url(:thumb),
      "delete_url" => highlight_image.url(:thumb),
      "delete_type" => "DELETE" ,
      "id" => self.id
    }
  end
end
