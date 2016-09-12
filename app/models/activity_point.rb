class ActivityPoint < ActiveRecord::Base

  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am, :end_time_hour, :end_time_minute ,:end_time_am

  belongs_to :event

  validates :action, :action_point, presence: { :message => "This field is required." }#, :start_activity_date, :end_activity_date, presence: { :message => "This field is required." }
  validates_uniqueness_of :action, :message => "Name already exists."

  before_validation :set_time
  #after_save :set_end_date_if_end_date_not_selected
  # before_save :set_one_time_point_value

  # def set_one_time_point_value
  #   self.one_time_only = false if self.one_time_only == true
  #   self.save
  # end

	def set_time
    start_date = self.start_activity_date rescue nil
    end_date = self.end_activity_date rescue nil
    start_time = "#{start_date.strftime('%d/%m/%Y')} #{self.start_time_hour.gsub(':', "") rescue nil}:#{self.start_time_minute.gsub(':', "")  rescue nil}:#{0} #{self.start_time_am}" if start_date.present?
    end_time = "#{end_date.strftime('%d/%m/%Y')} #{self.end_time_hour.gsub(':', "")  rescue nil}:#{self.end_time_minute.gsub(':', "")  rescue nil}:#{0} #{self.end_time_am}" if end_date.present?
    self.start_activity_time = start_time.to_time if start_date.present?
    self.end_activity_time = end_time.to_time if end_date.present?
  end

  def set_end_date_if_end_date_not_selected
    end_activity_time = "#{self.end_time_hour.gsub(':', "")  rescue nil}:#{self.end_time_minute.gsub(':', "")  rescue nil}:#{0} #{self.end_time_am}" if self.end_activity_time.blank? and self.end_time_hour.present? and self.end_time_minute.present? and self.end_time_am.present?
    if self.start_activity_time.to_date.present? and end_activity_time.present?
      self.end_activity_time = "#{self.start_activity_time.strftime('%d/%m/%Y')} #{end_activity_time}"
      self.save
    end
  end

end
