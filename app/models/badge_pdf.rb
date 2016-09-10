class BadgePdf < ActiveRecord::Base
  belongs_to :event
  validates_uniqueness_of :event_id,:message => "Badge image for Event already set."
  validate :badge_image_validate
  has_attached_file :badge_image
  validates_attachment_content_type :badge_image, :content_type => ["image/png", "image/jpg", "image/jpeg"],:message => "please select valid format."
  has_attached_file :badge_image, {:styles => {:large => "396x554>", 
                                       :thumb => "60x60>"}
                                       }.merge(BADGE_IMAGE_PATH)
  def badge_image_validate
    if self.badge_image_file_name_changed?  
      badge_dimension_height  = 554.0
      badge_dimension_width = 396.0
      dimensions = Paperclip::Geometry.from_file(badge_image.queued_for_write[:original].path)
      if (dimensions.width != badge_dimension_width or dimensions.height != badge_dimension_height)
        errors.add(:badge_image, "Image size should be 396x554px only")
      end
    end
  end
end