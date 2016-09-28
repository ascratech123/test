class QnaWall < ActiveRecord::Base
	belongs_to :event

	has_attached_file :logo
  validates_attachment_content_type :logo, :content_type => ["image/png", "image/jpg", "image/jpeg"],:message => "please select valid format."
  has_attached_file :logo, {:styles => {:large => "200x200>", 
                                       :thumb => "60x60>"}
                                       }.merge(QNAWALL_LOGO_PATH)
  has_attached_file :background_image
  validates_attachment_content_type :background_image, :content_type => ["image/png", "image/jpg", "image/jpeg"],:message => "please select valid format."
  has_attached_file :background_image, {:styles => {:large => "900x1600>", 
                                       :thumb => "60x60>"}
                                       }.merge(QNAWALL_BG_IMAGE_PATH)
  
  # validate :backgroung_image_validate
  
  # def backgroung_image_validate
  #   if self.background_image_file_name_changed?  
  #     background_image_dimension_height  = 960.0
  #     background_image_dimension_width = 1600.0
  #     dimensions = Paperclip::Geometry.from_file(background_image.queued_for_write[:original].path)
  #     if (dimensions.width != background_image_dimension_width or dimensions.height != background_image_dimension_height)
  #       errors.add(:background_image, "Image size should be 960x1600px only")
  #     end
  #   end
  # end

end
