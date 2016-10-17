class Agenda < ActiveRecord::Base
  
  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am, :end_time_hour, :end_time_minute ,:end_time_am, :new_category, :agenda_track_name_import
  belongs_to :event
  belongs_to :speaker
  belongs_to :agenda_track
  has_many :ratings, as: :ratable, :dependent => :destroy
  has_many :favorites, as: :favoritable, :dependent => :destroy
  
  validates :title,:start_agenda_date, :rating_status, presence: { :message => "This field is required." }
  validate :start_agenda_time_is_after_agenda_date
  validate :check_speaker_and_track_is_present
  validate :speakers_count
  
  before_validation :set_attr_accessor
  before_validation :set_time
  # before_save :set_agenda_speakers
  before_save :set_speaker_ids
  # after_save :set_speaker_name
  after_save :set_end_date_if_end_date_not_selected, :update_last_updated_model, :update_agenda_speakers
  before_save :check_category_present_if_new_category_select_from_dropdown
  after_create :set_event_timezone
  before_destroy :destroy_id_from_speaker

  default_scope { order('start_agenda_time asc') }

  def set_speaker_ids
    self.speaker_ids = self.speaker_ids.gsub("\"", "").sub("[", "").sub("]", "") if self.speaker_ids.present?
  end

  def destroy_id_from_speaker
    if self.speaker_ids.present?
      speaker_ids = self.speaker_ids.split(',') 
      speaker_ids = speaker_ids.reject { |e| e.to_s.empty? }
      speaker_ids.each do |speaker_id|
        speaker = Speaker.find(speaker_id)
        agenda_ids = speaker.all_agenda_ids.to_s.split(",")
        speaker.update_column("all_agenda_ids", (agenda_ids - [self.id.to_s]).join(","))
      end
    end
  end

  def update_agenda_speakers
    speaker_ids = self.speaker_ids.to_s.split(',')
    speaker_names = []
    speaker_ids.each do |speaker_id|
      speaker = Speaker.find(speaker_id)
      agenda_ids = (speaker.all_agenda_ids.to_s.split(",") + [self.id.to_s]).uniq.join(",")
      speaker.update_column(:all_agenda_ids, agenda_ids)
      speaker_names << speaker.speaker_name
    end if speaker_ids.present?
    all_speaker_names = (self.speaker_names.to_s.split(",") + speaker_names).uniq.join(",")
    self.update_column("all_speaker_names", all_speaker_names)
  end

  # def speaker_names
  #   self.agenda_speakers.pluck(:speaker_name).join(', ')
  # end

  # def speaker_ids
  #   self.speaker_name#agenda_speakers.pluck(:speaker_name).join(', ')
  # end

  def set_attr_accessor
    if self.start_time_hour.blank?
      prev_start_time_hour = self.start_agenda_time.strftime('%l').strip.rjust(2, '0') rescue nil
      self.start_time_hour = prev_start_time_hour.blank? ? "00" : prev_start_time_hour
    end
    
    if self.start_time_minute.blank?
      prev_start_time_minute = self.start_agenda_time.strftime('%M').strip.rjust(2, '0') rescue nil
      self.start_time_minute = prev_start_time_minute.blank? ? "00" : prev_start_time_minute
    end

    if self.start_time_am.blank?
      prev_start_time_am = self.start_agenda_time.strftime('%p') rescue "AM"
      self.start_time_am = prev_start_time_am.blank? ? "AM" : prev_start_time_am
    end

    if self.end_time_hour.blank?
      prev_end_time_hour = self.end_agenda_time.strftime('%l').strip.rjust(2, '0') rescue nil
      self.end_time_hour = prev_end_time_hour.blank? ? "" : prev_end_time_hour
    end

    if self.end_time_minute.blank?
      prev_end_time_minute = self.end_agenda_time.strftime('%M').strip.rjust(2, '0') rescue nil
      self.end_time_minute = prev_end_time_minute.blank? ? "" : prev_end_time_minute
    end

    if self.end_time_am.blank?
      prev_end_time_am = self.end_agenda_time.strftime('%p') rescue "PM"
      self.end_time_am = prev_end_time_am.blank? ? "" : prev_end_time_am
    end    

  end

  def start_agenda_time_is_after_agenda_date
    return if self.start_agenda_time.blank? 
    start_event_date = self.event.start_event_time rescue nil
    end_event_date = self.event.end_event_time rescue nil
    start_agenda_time = self.start_agenda_time rescue nil
    end_agenda_time = self.end_agenda_time rescue nil
    
    if start_event_date.present? and end_event_date.present? and start_agenda_time.present?
      if !start_agenda_time.between?(start_event_date, end_event_date)
        errors.add(:start_agenda_date, "Date must be between event dates")
      end
    end
    if start_event_date.present? and end_event_date.present? and start_agenda_time.present? and end_agenda_time.present?
      if !end_agenda_time.between?(start_event_date, end_event_date)
        errors.add(:end_agenda_date, "Date must be between event dates")
      end
    end
    if start_agenda_time.present? and end_agenda_time.present?
      if start_agenda_time >= end_agenda_time
        errors.add(:end_agenda_date, "cannot be before the start date")
      end
    end
  end

  def set_speaker_name
    if self.speaker_id.present? and self.speaker_id != 0
      name = Speaker.find(self.speaker_id).speaker_name
      self.update_column(:speaker_name ,name)
    end
  end

  def set_agenda_speakers
    if self.speaker_name_changed?  or self.agenda_speaker_form_data.present?
      self.agenda_speakers = []
      self.agenda_speakers_attributes = self.speaker_name.split(",").collect{|s, i| {"speaker_id" => 0, "speaker_name" => s}}
    end
  end

  def set_time
    start_date = self.start_agenda_date rescue nil
    end_date = self.end_agenda_date rescue nil
    start_time = "#{start_date.strftime('%d/%m/%Y')} #{self.start_time_hour.gsub(':', "") rescue nil}:#{self.start_time_minute.gsub(':', "")  rescue nil}:#{0} #{self.start_time_am}" if start_date.present?
    end_time = "#{end_date.strftime('%d/%m/%Y')} #{self.end_time_hour.gsub(':', "")  rescue nil}:#{self.end_time_minute.gsub(':', "")  rescue nil}:#{0} #{self.end_time_am}" if end_date.present?
    self.start_agenda_time = start_time.to_datetime if start_date.present?
    self.end_agenda_time = end_time.to_datetime if end_date.present?
  end

  def set_end_date_if_end_date_not_selected
    end_agenda_time = "#{self.end_time_hour.gsub(':', "")  rescue nil}:#{self.end_time_minute.gsub(':', "")  rescue nil}:#{0} #{self.end_time_am}" if self.end_agenda_time.blank? and self.end_time_hour.present? and self.end_time_minute.present? and self.end_time_am.present?
    if self.start_agenda_time.to_date.present? and end_agenda_time.present?
#    if self.start_agenda_date.present? and end_agenda_time.present?
      self.end_agenda_time = "#{self.start_agenda_time.strftime('%d/%m/%Y')} #{end_agenda_time}"
      self.save
    end
  end

  def set_event_timezone
    event = self.event
    self.update_column("event_timezone", event.timezone)
    self.update_column("event_timezone_offset", event.timezone_offset)
    self.update_column("event_display_time_zone", event.display_time_zone)
  end  

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def check_category_present_if_new_category_select_from_dropdown
    if self.agenda_type == "Add New Track" and self.new_category.present?
      self.agenda_type = self.new_category
    else
      self.agenda_type = nil if self.agenda_type == "Add New Track"
    end
  end

  def check_speaker_and_track_is_present
    if self.speaker_id == 0 
      errors.add(:speaker_name, "This field is required.") if self.speaker_name.blank?
    end
    if self.agenda_type == "Add New Track"
      errors.add(:new_category, "This field is required.") if self.new_category.blank?
    end
  end

  def speakers_count
   if self.speaker_ids.present? or self.speaker_names.present?
     speaker_ids_count = self.speaker_ids.to_s.split(",").count
     speaker_names_count = self.speaker_names.to_s.split(",").count
     if (speaker_ids_count + speaker_names_count) > 5
       errors.add(:speaker_names, "you can add upto 5 speakers") if self.speaker_names.present?
       errors.add(:speaker_ids, "you can add upto 5 speakers") if self.speaker_ids.present?
     end
   end
  end

  def agenda_type
    self.agenda_track.present? ? self.agenda_track.track_name : ""
  end

  def set_sequence_no
    self.sequence = (Event.find(self.event_id).agendas.pluck(:sequence).compact.max.to_i + 1)rescue nil
  end
  
  def get_agenda_type_name
    self.agenda_type
    id = []
    id <<  self.id
    Agenda.where("id IN (?)",id).pluck(:agenda_type).join
  end  

  def agenda_track_name
    self.agenda_track.track_name if self.agenda_track_id.to_i > 0
  end

  def track_sequence
    self.agenda_track.sequence if self.agenda_track_id.to_i > 0
  end

  def formatted_start_date_detail
    "#{self.start_agenda_time.strftime('%d %B %Y')}"if self.start_agenda_time.present?
  end

  def formatted_time
    # timezone = self.start_agenda_time.in_time_zone(self.event_timezone).strftime("%:z") if self.start_agenda_time.present?
    if self.end_agenda_time.present? and self.start_agenda_time.present?
      self.start_agenda_time.strftime('%l:%M %p') + " - " + self.end_agenda_time.strftime('%l:%M %p (') + self.event_display_time_zone.to_s + ")"
    elsif self.start_agenda_time.present?
      self.start_agenda_time.strftime('%l:%M %p Onwards (')  + self.event_display_time_zone.to_s + ")"
    end
  end

  def formatted_time_without_timezone
    if self.end_agenda_time.present? and self.start_agenda_time.present?
      self.start_agenda_time.strftime('%l:%M %p') + " - " + self.end_agenda_time.strftime('%l:%M %p')
    elsif self.start_agenda_time.present?
      self.start_agenda_time.strftime('%l:%M %p Onwards') 
    end
  end

  def formatted_start_date_listing
    "#{self.start_agenda_time.strftime('%d-%b-%y')}" if self.start_agenda_time.present?
  end
end