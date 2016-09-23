class Registration < ActiveRecord::Base
  serialize :field1
  serialize :field2
  serialize :field3
  serialize :field4
  serialize :field5
  serialize :field6
  serialize :field7
  serialize :field8
  serialize :field9
  serialize :field10
  serialize :field11
  serialize :field12
  serialize :field13
  serialize :field14
  serialize :field15
  serialize :field16
  serialize :field17
  serialize :field18
  serialize :field19
  serialize :field20

  belongs_to :event
  has_many :user_registrations
  
  attr_accessor :label,:option_type,:validation_type,:option_1,:option_2,:option_3,:option_4
  
  validate :mandate_field_check
  after_save :update_last_updated_model

  default_scope { order('created_at desc') }

  def mandate_field_check
    field = self.field1
      if field[:label].blank? or field[:option_type].blank? or field[:validation_type].blank? or field[:option_1].blank? or field[:option_2].blank?
        errors.add(:label, "This field is required.") if field[:label].blank?
        errors.add(:option_type, "This field is required.") if field[:option_type].blank?
        errors.add(:validation_type, "This field is required.") if field[:validation_type].blank?
        errors.add(:option_1, "This field is required.") if ((field[:option_type] == "Check Box" or field[:option_type] == "Radio Button") and field[:option_1].blank?)
        errors.add(:option_2, "This field is required.") if ((field[:option_type] == "Check Box" or field[:option_type] == "Radio Button") and field[:option_2].blank?)
    end
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

end
