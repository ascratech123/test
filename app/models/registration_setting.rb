class RegistrationSetting < ActiveRecord::Base
  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am, :end_time_hour, :end_time_minute ,:end_time_am,:start_date_time,:end_date_time
  belongs_to :event 

  validates :event_id, :registration, :start_date_time, :on_mobile_app, :end_date_time, presence: true   # :login,
  # validates :login_url, :login_surl, :reg_url, :reg_surl, presence: true, :if :registration == 'hobnob'
  # validates :forget_pass_url, :forget_pass_surl, presence: true
  validate :check_external_regi_and_login_present

  before_validation :set_attr_accessor,:set_time
  before_save :update_registation_login_url,:update_template_to_template_name
  after_save :update_registation_surl, :update_last_updated_model

  attr_accessor :template_name
  
  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def update_registation_login_url
    if self.login == 'hobnob'
      event = self.event
      mobile_application = event.mobile_application
      self.login_url = "#{APP_URL}/admin/mobile_applications/#{mobile_application.id}/external_login?mobile_application_preview_code=#{mobile_application.preview_code}&mobile_application_code=#{mobile_application.submitted_code}"
      self.login_surl = "#{APP_URL}/admin/mobile_applications/#{mobile_application.id}/success"
    end
  end

  def update_registation_surl
    if self.registration == 'hobnob'
      event = self.event
      self.update_column(:reg_url ,"#{APP_URL}/admin/events/#{event.id}/user_registrations/new")
      self.update_column(:reg_surl ,"#{APP_URL}/admin/events/#{event.id}/success")
    end
  end
  def check_external_regi_and_login_present
    if self.registration == "external"
      errors.add(:external_reg_url, "This field is required.") if self.external_reg_url.blank?
      errors.add(:external_reg_surl, "This field is required.") if self.external_reg_surl.blank?
    end
    if self.login == "external"
      errors.add(:external_login_url, "This field is required.") if self.external_login_url.blank?
      errors.add(:external_login_surl, "This field is required.") if self.external_login_surl.blank?
    end
    if self.registration == "hobnob"
      errors.add(:template, "This field is required.") if self.template.blank?
    end
    if self.registration == "hobnob" and self.template.present? and self.template == "default"
      errors.add(:template_name, "This field is required.") if template_name.blank?
    end
  end

  def update_template_to_template_name
    if self.template.present? and self.template == "default" 
      self.template = template_name if template_name.present?
    end
  end

  def set_attr_accessor
    if self.start_time_hour.blank?
      prev_start_time_hour = self.start_date.strftime('%l').strip.rjust(2, '0') rescue nil
      self.start_time_hour = prev_start_time_hour.blank? ? "00" : prev_start_time_hour
    end
    
    if self.start_time_minute.blank?
      prev_start_time_minute = self.start_date.strftime('%M').strip.rjust(2, '0') rescue nil
      self.start_time_minute = prev_start_time_minute.blank? ? "00" : prev_start_time_minute
    end

    if self.start_time_am.blank?
      prev_start_time_am = self.start_date.strftime('%p') rescue "AM"
      self.start_time_am = prev_start_time_am.blank? ? "AM" : prev_start_time_am
    end

    if self.end_time_hour.blank?
      prev_end_time_hour = self.end_date.strftime('%l').strip.rjust(2, '0') rescue nil
      self.end_time_hour = prev_end_time_hour.blank? ? "" : prev_end_time_hour
    end

    if self.end_time_minute.blank?
      prev_end_time_minute = self.end_date.strftime('%M').strip.rjust(2, '0') rescue nil
      self.end_time_minute = prev_end_time_minute.blank? ? "" : prev_end_time_minute
    end

    if self.end_time_am.blank?
      prev_end_time_am = self.end_date.strftime('%p') rescue "PM"
      self.end_time_am = prev_end_time_am.blank? ? "" : prev_end_time_am
    end    

  end

  def set_time
    start_date = self.start_date_time rescue nil
    end_date = self.end_date_time rescue nil
    start_time = "#{start_date} #{self.start_time_hour.gsub(':', "") rescue nil}:#{self.start_time_minute.gsub(':', "")  rescue nil}:#{0} #{self.start_time_am}" if start_date.present?
    end_time = "#{end_date} #{self.end_time_hour.gsub(':', "")  rescue nil}:#{self.end_time_minute.gsub(':', "")  rescue nil}:#{0} #{self.end_time_am}" if end_date.present?
    self.start_date = start_time.to_datetime if start_date.present?
    self.end_date = end_time.to_datetime if end_date.present?
  end

end
