class Microsite < ActiveRecord::Base
  attr_accessor :set_custom_template, :fields_validation#, :start_time_hour, :start_time_minute, :start_time_am, :start_date_time, 
  serialize :social_icons, Array

  belongs_to :event
  has_many :user_microsites

  has_attached_file :header_image, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(MICROSITE_HEADER_IMAGE_PATH)

  has_attached_file :banner_image, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(MICROSITE_BANNER_IMAGE_PATH)

  has_attached_file :logo_image, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(MICROSITE_LOGO_IMAGE_PATH)

  # validates :template_type, presence: true, :if => Proc.new {|c| check_custom_template.present?}
  validates_attachment_content_type :header_image, :banner_image, :logo_image, :content_type => ["image/png", "image/jpg", "image/jpeg"], :message => "please select valid format."
  # before_validation :set_sent_to_no
  before_save :check_header_image
  after_save :create_micro_url
  validate :image_dimensions_for_header, :image_dimensions_for_banner, :image_dimensions_for_logo, :check_custom_template, :mandate_field_check

  # def set_sent_to_no
  #   if self.new_record? and self.sent.blank?
  #     self.sent = 'no'
  #   end
  # end

  def mandate_field_check
    if self.set_custom_template == "true" and self.default_template.present? and self.fields_validation == "true"
      if self.field1.blank?
        errors.add(:field1, "This field is required.")
      end
    end
  end

  def check_custom_template
    if self.set_custom_template == "true" and not self.default_template.present?
      errors.add(:default_template, "Please select template")
    end
  end

  def create_micro_url
    self.update_column(:micro_url ,"#{APP_URL}/admin/events/#{event.id}/microsite_templates/new?microsite_id=#{self.id}")
  end

  def check_header_image
    if self.header_image.present? and self.header_color.present?
      self.header_color = ""
    end
  end

  # def set_time(start_date_time, start_time_hour, start_time_minute, start_time_am)
  #   start_date = start_date_time rescue nil
  #   start_date = "#{start_date} #{start_time_hour.gsub(':', "") rescue nil}:#{start_time_minute.gsub(':', "")rescue nil}:#{0} #{start_time_am}" if start_date.present?
  #   self.microsite_broadcast_time = start_date.to_time rescue nil
  #     return start_date.to_time rescue nil
  # end

  # def self.send_email_time_basis
  #   microsites = Microsite.where("sent != ? and microsite_broadcast_time < ? and microsite_broadcast_time > ?", 'yes', (Time.zone.now).to_formatted_s(:db), (Time.zone.now - 30.minutes).to_formatted_s(:db))
  #   if microsites.present?
  #     microsites.each do |microsite|
  #       microsite.send_mail_to_invitees
  #     end
  #   end
  # end

  # def check_template_or_custom_is_present
  #   if self.template_type == "custom_template"
  #     errors.add(:custom_code, "This field is required.") if self.custom_code.blank?
  #   end
  # end

  def image_dimensions_for_header
    if header_image_file_name.present? and header_image_file_name_changed?
      microsite_header_image_height, microsite_header_image_width  = 100.0, 600.0
      dimensions_header_image = Paperclip::Geometry.from_file(header_image.queued_for_write[:original].path) if header_image_file_name.present?
      errors.add(:header_image, "Image size should be 600x100px only") if (dimensions_header_image.width != microsite_header_image_width or dimensions_header_image.height != microsite_header_image_height)
    end
  end

  def image_dimensions_for_logo
    if logo_image_file_name.present? and logo_image_file_name_changed?
      microsite_logo_image_height, microsite_logo_image_width  = 50.0, 140.0
      dimensions_logo_image = Paperclip::Geometry.from_file(logo_image.queued_for_write[:original].path) if logo_image_file_name.present?
      errors.add(:logo_image, "Image size should be 140x50px only") if (dimensions_logo_image.width != microsite_logo_image_width or dimensions_logo_image.height != microsite_logo_image_height)
    end
  end

  def image_dimensions_for_banner
    if banner_image_file_name.present? and banner_image_file_name_changed?
      microsite_banner_image_height, microsite_banner_image_width  = 320.0, 850.0
      dimensions_banner_image = Paperclip::Geometry.from_file(banner_image.queued_for_write[:original].path) if banner_image_file_name.present?
      errors.add(:banner_image, "Image size should be 850x320px only") if (dimensions_banner_image.width != microsite_banner_image_width or dimensions_banner_image.height != microsite_banner_image_height)
    end
  end
    
end
