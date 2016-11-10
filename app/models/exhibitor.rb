class Exhibitor < ActiveRecord::Base
  
  belongs_to :event
  has_attached_file :image, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80",
                                         :thumb => "-strip -quality 80"}
                                         }.merge(EXHIBITOR_IMAGE_PATH)
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png"],:message => "please select valid format."
  validates :name,:image, presence:{ :message => "This field is required." }
  validates :email,
            :format => {
            :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
            :message => "Sorry, this doesn't look like a valid email." }, :allow_blank => true
  validate :image_dimensions
  before_create :set_sequence_no
  after_save :update_last_updated_model, :clear_cache
  after_destroy :clear_cache
  
  default_scope { order('sequence') }

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def clear_cache
    Rails.cache.delete("exhibitors_json_#{self.event.mobile_application_id}_published")
    Rails.cache.delete("exhibitors_json_#{self.event.mobile_application_id}_approved_published")
  end

  def image_url(style=:small)
    style.present? ? self.image.url(style) : self.image.url
  end

  def set_sequence_no
    self.sequence = (Event.find(self.event_id).exhibitors.pluck(:sequence).compact.max.to_i + 1)rescue nil
  end

  def image_dimensions
    if self.image_file_name_changed?  
      image_dimension_height  = 300.0
      image_dimension_width = 300.0
      dimensions = Paperclip::Geometry.from_file(image.queued_for_write[:original].path)
      if (dimensions.width != image_dimension_width or dimensions.height != image_dimension_height)
        errors.add(:image, "Image size should be 300x300px only")
      else
        self.errors.delete(:image)
      end
    end
  end

end
