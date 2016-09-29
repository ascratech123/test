class QnaWall < ActiveRecord::Base
	belongs_to :event

	has_attached_file :logo
  validates_attachment_content_type :logo, :content_type => ["image/png"],:message => "please select valid format."
  has_attached_file :logo, {:styles => {:large => "200x200>", 
                                       :thumb => "60x60>"}
                                       }.merge(QNAWALL_LOGO_PATH)
  has_attached_file :background_image
  validates_attachment_content_type :background_image, :content_type => ["image/png"],:message => "please select valid format."
  has_attached_file :background_image, {:styles => {:large => "900x1600>", 
                                       :thumb => "60x60>"}
                                       }.merge(QNAWALL_BG_IMAGE_PATH)
  
  #validates :background_image, presence:{ :message => "This field is required." }
  #validates :bg_color, presence:{ :message => "This field is required." }
  validate :backgroung_image_validate
  validate :logo_image_validate
  validate :bg_image_or_bg_color_exist

  def bg_image_or_bg_color_exist
    if self.background_image.blank? and self.bg_color.blank?
      errors.add(:bg_color, "This field is required.")
    end  
  end

  def backgroung_image_validate
    if self.background_image_file_name_changed?  
      background_image_dimension_height  = 900.0
      background_image_dimension_width = 1600.0
      dimensions = Paperclip::Geometry.from_file(background_image.queued_for_write[:original].path) rescue nil
      if dimensions.present?
        if (dimensions.width != background_image_dimension_width or dimensions.height != background_image_dimension_height)
          errors.add(:background_image, "Image size should be 1600x900px only")
        end
      end  
    end
  end
  
  def logo_image_validate 
    if self.logo_file_name_changed?  
      logo_dimension_height  = 300.0
      logo_dimension_width = 1280.0
      dimensions = Paperclip::Geometry.from_file(logo.queued_for_write[:original].path) rescue nil
      if dimensions.present?
        if (dimensions.width != logo_dimension_width or dimensions.height != logo_dimension_height)
          errors.add(:logo, "Image size should be 1280x300px only")
        end
      end  
    end
  end  

end


