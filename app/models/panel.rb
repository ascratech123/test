class Panel < ActiveRecord::Base
  
  belongs_to :event
  # validates :panel_id, presence: true
  validate :check_speaker_is_present
  before_create :set_sequence_no
  default_scope { order("sequence") }

  def check_speaker_is_present
    if self.panel_id.present? and self.panel_id == 0 
      errors.add(:speaker_name, "This field is required.") if self.name.blank?
    end
  end

  def set_sequence_no
    self.sequence = (Panel.where(:event_id => self.event_id).pluck(:sequence).compact.max.to_i + 1)rescue nil
  end
end