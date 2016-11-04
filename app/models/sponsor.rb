class Sponsor < ActiveRecord::Base
  belongs_to :event
  has_many :images, as: :imageable, :dependent => :destroy
  attr_accessor :new_category,:image

  before_save :add_new_category

  validates :email,
            :allow_blank => true,
            :format => {
              :with    => /\A[\w]([^@\s,;]+)@(([\w-]+\.)+(com|edu|org|net|gov|mil|biz|info|in))\z/i,
              :message => "Sorry, this doesn't look like a valid email." }
  validate :image_dimensions 
  validate :check_category_in_present             
  has_attached_file :logo, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(SPONSOR_IMAGE_PATH)

  validates_attachment_content_type :logo, :content_type => ["image/jpg", "image/jpeg", "image/png"],:message => "please select valid format."
  validates :sponsor_type,:name, presence: { :message => "This field is required." }
  validates :email,
            :format => {
            :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
            :message => "Sorry, this doesn't look like a valid email." }, :allow_blank => true
  validate :check_logo_is_present
  accepts_nested_attributes_for :images
  before_create :set_sequence_no
  after_save :update_last_updated_model, :clear_cache
  after_destroy :clear_cache

  default_scope { order("sequence") }

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def clear_cache
    Rails.cache.delete("sponsors_json_#{self.event.mobile_application_id}_published")
    Rails.cache.delete("sponsors_json_#{self.event.mobile_application_id}_approved_published")
  end

  def self.search(params,sponsors)
    sponsor_type = params[:search]
    sponsors = sponsors.where("sponsor_type like (?) ", "%#{sponsor_type}%") if sponsor_type.present?
    sponsors
  end

  def image_url
    self.logo.url rescue nil
  end

  def add_new_category
    if self.sponsor_type == "New Category"
      self.sponsor_type = self.new_category
      self.save
    end
  end

  def check_logo_is_present
    if self.logo.blank?
      errors.add(:logo, "This field is required.")
    end  
  end 

  def set_sequence_no
    self.sequence = (Event.find(self.event_id).sponsors.pluck(:sequence).compact.max.to_i + 1)rescue nil
  end

  def image_dimensions
    if self.logo_file_name_changed?  
      logo_dimension_height  = 300.0
      logo_dimension_width = 300.0
      dimensions = Paperclip::Geometry.from_file(logo.queued_for_write[:original].path)
      if (dimensions.width != logo_dimension_width or dimensions.height != logo_dimension_height)
        errors.add(:logo, "Image size should be 300x300px only")
      else
        self.errors.delete(:logo)
      end
    end
  end
  
  def check_category_in_present
    if self.sponsor_type.present? and self.sponsor_type == "New Category"
      errors.add(:new_category, "This field is required.") if self.new_category.blank?
    end
  end
end
