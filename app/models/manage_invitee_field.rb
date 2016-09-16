class ManageInviteeField < ActiveRecord::Base
  serialize :field_attr, Hash
  belongs_to :event

  DISPLAY_FIELD_NAME = {"first_name"=>"First Name", "last_name"=>"Last Name", "email"=>"Email", "company_name"=>"Company Name", "designation"=>"Designation"}

  def get_column_names
    hsh = DISPLAY_FIELD_NAME
    hsh
  end

end

