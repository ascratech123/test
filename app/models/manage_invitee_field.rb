class ManageInviteeField < ActiveRecord::Base
  serialize :field_attr, Hash
  belongs_to :event

  DISPLAY_FIELD_NAME = {"name_of_the_invitee"=>"Full Name", "email"=>"Email", "company_name"=>"Company Name", "designation"=>"Designation"}

  def get_column_names
    hsh = DISPLAY_FIELD_NAME
    hsh
  end

end

