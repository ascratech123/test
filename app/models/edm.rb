class Edm < ActiveRecord::Base
  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am,:start_date_time
  belongs_to :campaign
  has_attached_file :header_image, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(HEADER_IMAGE_PATH)

  has_attached_file :footer_image, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(FOOTER_IMAGE_PATH)

  # before_validation :set_time, :if => Proc.new{}
  validate :check_template_or_custom_is_present
  validates_attachment_content_type :header_image,:footer_image, :content_type => ["image/png"],:message => "please select valid format."

  def set_time(start_date_time,start_time_hour,start_time_minute,start_time_am)
    start_date = start_date_time rescue nil
    start_date = "#{start_date} #{start_time_hour.gsub(':', "") rescue nil}:#{start_time_minute.gsub(':', "")  rescue nil}:#{0} #{start_time_am}" if start_date.present?
      # self.edm_broadcast_time = start_date.to_time rescue nil
      return start_date.to_time rescue nil
  end

  def check_template_or_custom_is_present
    # if self.template_type == "default_template" 
    #   errors.add(:default_template, "This field is required.") if self.default_template.blank?
    # end
    if self.template_type == "custom_template"
      errors.add(:custom_code, "This field is required.") if self.custom_code.blank?
    end
  end
end
