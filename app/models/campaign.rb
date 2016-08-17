class Campaign < ActiveRecord::Base
  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am, :end_time_hour, :end_time_minute ,:end_time_am, :start_date_time, :end_date_time

  belongs_to :event
  has_many :edms, :dependent => :destroy
  validates :campaign_name, presence:{ :message => "This field is required." } 
  # before_validation :set_time

  def set_time
    start_date = self.start_date_time rescue nil
    end_date = self.end_date_time rescue nil
    start_date = "#{start_date} #{self.start_time_hour.gsub(':', "") rescue nil}:#{self.start_time_minute.gsub(':', "")  rescue nil}:#{0} #{self.start_time_am}" if start_date.present?
    end_date = "#{end_date} #{self.end_time_hour.gsub(':', "")  rescue nil}:#{self.end_time_minute.gsub(':', "")  rescue nil}:#{0} #{self.end_time_am}" if end_date.present?
      self.start_date = start_date.to_time rescue nil
      self.end_date = end_date.to_time rescue nil
  end
end
