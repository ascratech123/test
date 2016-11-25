class Course < ActiveRecord::Base
  attr_accessor :start_time_date, :start_time_hour, :start_time_minute, :start_time_am, :end_time_date, :end_time_hour, :end_time_minute, :end_time_am, :tags

  has_many :course_tags
  has_many :course_providers
  belongs_to :event

  validates_presence_of :title, :code

  before_create :set_sequence_no
  before_save :correct_speaker_ids, :save_date_time, :update_course_tags
  after_save :update_all_speaker_names, :update_speakers, :update_last_updated_model

  default_scope { order('sequence') }

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def set_sequence_no
    self.sequence = (self.event.courses.pluck(:sequence).compact.max.to_i + 1)
  end

  def correct_speaker_ids
    self.speaker_ids = self.speaker_ids.to_s.gsub("\"", "").sub("[", "").sub("]", "").gsub(" ", "").gsub(",", ", ")
  end

  def save_date_time
    self.start_time = "#{self.start_time_date} #{self.start_time_hour}:#{self.start_time_minute} #{self.start_time_am}".to_datetime if self.start_time_date.present?
    self.end_time = "#{self.end_time_date} #{self.end_time_hour}:#{self.end_time_minute} #{self.end_time_am}".to_datetime if self.end_time_date.present?
  end

  def update_all_speaker_names
    if self.speaker_ids_changed? or self.speaker_names_changed?
      all_names = []
      self.speaker_ids.to_s.split(", ").each{|lid| all_names << Speaker.find(lid).speaker_name}
      all_names << self.speaker_names if self.speaker_names.present?
      all_names = all_names.join(", ")
      self.update_column("all_speaker_names", all_names)
    end
  end

  def update_speakers
    if self.speaker_ids_changed?
      for speaker_id in speaker_ids.to_s.split(", ")
        speaker = Speaker.find(speaker_id)
        course_ids = speaker.course_ids.to_s.split(", ")
        course_ids << self.id if !speaker.course_ids.to_s.split(", ").include? self.id
        speaker.update_column("course_ids" , course_ids.join(", "))
        speaker.update_last_updated_model
        speaker.update_column("updated_at", Time.now)
      end
    end
  end

  def update_course_tags
    if self.tags.present?
      tags = self.tags.split(",").map{|t| {"tag_name" => t.strip}}
      self.course_tags.build(tags)
    end
  end

end
