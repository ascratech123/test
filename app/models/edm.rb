class Edm < ActiveRecord::Base
  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am,:start_date_time
  belongs_to :campaign
  serialize :social_icons, Array

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
  validates_attachment_content_type :header_image,:footer_image, :content_type => ["image/png", "image/jpg", "image/jpeg"],:message => "please select valid format."
  # after_save :send_mail_to_invitees
  before_validation :set_sent_to_no

  def set_sent_to_no
    if self.new_record? and self.sent.blank?
      self.sent = 'no'
    end
  end

  def set_time(start_date_time,start_time_hour,start_time_minute,start_time_am)
    start_date = start_date_time rescue nil
    start_date = "#{start_date} #{start_time_hour.gsub(':', "") rescue nil}:#{start_time_minute.gsub(':', "")rescue nil}:#{0} #{start_time_am}" if start_date.present?
    self.edm_broadcast_time = start_date.to_time rescue nil
      return start_date.to_time rescue nil
  end

  def self.send_email_time_basis
    puts "*************EDM********#{Time.now}**********************"
    edms = Edm.where("sent != ? and edm_broadcast_time < ? and edm_broadcast_time > ?", 'yes', (Time.zone.now).to_formatted_s(:db), (Time.zone.now - 30.minutes).to_formatted_s(:db))
    if edms.present?
      edms.each do |edm|
        edm.send_mail_to_invitees
      end
    end
  end

  def send_mail_to_invitees
    if self.edm_broadcast_value == 'now'
      edm = self
      self.update_column(:edm_broadcast_time, Time.now)
      self.update_column(:sent, 'yes')
      final_emails_arr = []
      campaign = self.campaign
      event = campaign.event
      smtp_setting = event.get_licensee_admin.smtp_setting
      invitee_structure = event.invitee_structures.last
      database_email_field = invitee_structure.email_field rescue nil
      if edm.group_type == 'apply filter'
        registration = event.registrations.last
        registration_email_field = registration.email_field rescue nil
        user_registrations = UserRegistration.where(:registration_id => registration.id) if registration.present?
        user_registration_emails = []
        if user_registrations.present?
          if edm.registered == 'yes' and registration_email_field.present?
            user_registration_emails = user_registrations.pluck("#{registration_email_field}")
          elsif edm.registered == 'no' and registration_email_field.present? and database_email_field.present?
            user_registration_emails = user_registrations.pluck("#{registration_email_field}")
            if user_registration_emails.present? and 
              user_registration_emails = InviteeDatum.where("invitee_structure_id = ? and #{database_email_field} Not IN (?)", invitee_structure.id, user_registration_emails).pluck("#{database_email_field}")
            else
              user_registration_emails = InviteeDatum.where(:invitee_structure_id => invitee_structure.id).pluck("#{database_email_field}")
            end
          end
        end    
        user_registration_approved_emails = []
        if user_registrations.present? and registration_email_field.present?
          if edm.registration_approved == 'yes'
            user_registration_approved_emails = user_registrations.where(:status => 'approved').pluck("#{registration_email_field}")
          elsif edm.registered == 'no'
            user_registration_approved_emails = user_registrations.where('status != ?', registration.id, 'approved').pluck("#{registration_email_field}")
          else
            user_registration_approved_emails = user_registrations.pluck("#{registration_email_field}")
          end
        end
        if edm.confirmed.present?
          confirm_emails = Invitee.where(:event_id => event.id, :invitee_status => edm.confirmed).pluck(:email)
        else
          confirm_emails = Invitee.where(:event_id => event.id).pluck(:email)
        end

        if edm.attended.present?# == 'yes'
          attended_emails = Invitee.where(:event_id => event.id).pluck(:email)#, :attended => edm.attended).pluck(:email)
        else
          attended_emails = Invitee.where(:event_id => event.id).pluck(:email)
        end
        final_emails_arr = confirm_emails
        final_emails_arr = final_emails_arr & attended_emails if attended_emails.present?

        final_emails_arr = (user_registration_emails.present? ? (final_emails_arr.present? ? final_emails_arr & user_registration_emails : user_registration_emails) : final_emails_arr)

        final_emails_arr = (user_registration_approved_emails.present? ? (final_emails_arr.present? ? final_emails_arr & user_registration_approved_emails : user_registration_approved_emails) : final_emails_arr)


        email_sent_yes = EdmMailSent.where(:edm_id => edm.id)
        email_sent_yes_arr = email_sent_yes.pluck(:email)
        if edm.email_sent == 'yes'
          final_emails_arr = final_emails_arr & email_sent_yes_arr
        elsif edm.email_sent == 'no'
          final_emails_arr = final_emails_arr - email_sent_yes_arr
        end

        email_opened_yes_arr = email_sent_yes.where(:open => 'yes').pluck(:email)
        if edm.email_opened == 'yes'
          final_emails_arr = final_emails_arr & email_opened_yes_arr
        elsif edm.email_opened == 'no'
          final_emails_arr = final_emails_arr - email_opened_yes_arr
        end
      else
        final_emails_arr = InviteeDatum.where(:invitee_structure_id => invitee_structure.id).pluck("#{database_email_field}") rescue []
      end
      
      if smtp_setting.present? and final_emails_arr.present?
        final_emails_arr.each do |email|
          email_sent = EdmMailSent.find_or_initialize_by(:event_id => event.id, :email => email, :edm_id => self.id)
          email_sent.save
          UserMailer.default_template(edm,email,smtp_setting).deliver_now if edm.template_type.present? and edm.template_type == "default_template"
          UserMailer.custom_template(edm,email,smtp_setting).deliver_now if edm.template_type.present? and edm.template_type == "custom_template"
        end
      end
    end
  end

  def check_template_or_custom_is_present
    # if self.template_type == "default_template" 
    #   errors.add(:default_template, "This field is required.") if self.default_template.blank?
    # end
    if self.template_type == "custom_template"
      errors.add(:custom_code, "This field is required.") if self.custom_code.blank?
    end
  end

  # def sent_mail(edm,event)
  #   grouping = Grouping.find(edm.group_id) rescue nil
  #   invitee_structure = event.invitee_structures.first if event.invitee_structures.present?
  #   invitee_data = invitee_structure.invitee_datum rescue nil
  #   data = Grouping.get_search_data_count(invitee_data, [grouping]) if grouping.present? and invitee_data.present?
  #   smtp_setting = SmtpSetting.last
  #   if smtp_setting.present? and data.present?
  #     data.each do |f|
  #       email = f["#{edm.database_email_field}"] 
  #       UserMailer.default_template(edm,email,smtp_setting).deliver_now if edm.template_type.present? and edm.template_type == "default_template"
  #       UserMailer.custom_template(edm,email,smtp_setting).deliver_now if edm.template_type.present? and edm.template_type == "custom_template"
  #     end
  #   end
  # end
end
