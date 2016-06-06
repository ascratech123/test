class Panel < ActiveRecord::Base
  
  belongs_to :event
  # validates :panel_id, presence: true
  validate :check_speaker_is_present
  default_scope { order('created_at desc') }

  def check_speaker_is_present
    if self.panel_id.present? and self.panel_id == 0 
      errors.add(:speaker_name, "This field is required.") if self.name.blank?
    end
  end
end
