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
  
  attr_accessor :label,:option_type,:validation_type,:option_1,:option_2,:option_3,:option_4,:option_5,:option_6,:option_7,:option_8,:option_9,:option_10,:mandatory_field,:text_box_required_after_options
  
  validate :mandate_field_check

  default_scope { order('created_at desc') }

  def mandate_field_check
    field = self.field1
      if field[:label].blank? or field[:option_type].blank? or field[:validation_type].blank? or field[:option_1].blank? or field[:option_2].blank?
        errors.add(:label, "This field is required.") if field[:label].blank?
        errors.add(:option_type, "This field is required.") if field[:option_type].blank?
        errors.add('field1[validation_type]', "This field is required.") if (field[:validation_type].blank? and (["Text Box","Text Area"].include?(field[:option_type])))
        errors.add('field1[option_1]', "This field is required.") if (["Radio Button","Check Box","Drop-Down list"].include?(field[:option_type]) and field[:option_1].blank?)
        errors.add('field1[option_2]', "This field is required.") if (["Radio Button","Check Box","Drop-Down list"].include?(field[:option_type]) and field[:option_2].blank?)
        errors.add('field1[text_box_required_after_options]', "This field is required.") if (["Radio Button","Check Box","Drop-Down list"].include?(field[:option_type]) and field[:text_box_required_after_options].blank?)
    end
  end
end