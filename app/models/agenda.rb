class Agenda < ActiveRecord::Base
  
  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am, :end_time_hour, :end_time_minute ,:end_time_am, :new_category
  belongs_to :event
  belongs_to :speaker
  has_many :ratings, as: :ratable, :dependent => :destroy
  has_many :favorites, as: :favoritable, :dependent => :destroy
  
  validates :title,:start_agenda_date, presence: { :message => "This field is required." }
  validate :start_agenda_time_is_after_agenda_date
  validate :check_speaker_and_track_is_present
  
  before_validation :set_time
  after_save :set_speaker_name
  after_save :set_end_date_if_end_date_not_selected
  before_save :check_category_present_if_new_category_select_from_dropdown

  default_scope { order('start_agenda_time asc') }

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
      time = "#{self.start_agenda_time.strftime('%d/%m/%Y')} #{end_agenda_time}"
      self.end_agenda_time = time.to_time rescue nil
      self.save
    end
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
end