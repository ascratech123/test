class MyTravel < ActiveRecord::Base
  belongs_to :event
  belongs_to :invitee
  has_attached_file :attach_file, {:styles => {:large => "640x640>",:small => "200x200>",
    :thumb => "60x60>"},
    :convert_options => {:large => "-strip -quality 90", 
                          :small => "-strip -quality 80", 
                          :thumb => "-strip -quality 80"}
                        }.merge(ATTACH_FILE_PATH)
  has_attached_file :attach_file_2, {:styles => {:large => "640x640>",:small => "200x200>",
    :thumb => "60x60>"},
    :convert_options => {:large => "-strip -quality 90", 
                          :small => "-strip -quality 80", 
                          :thumb => "-strip -quality 80"}
                        }.merge(ATTACH_FILE_2_PATH)
  has_attached_file :attach_file_3, {:styles => {:large => "640x640>",:small => "200x200>",
    :thumb => "60x60>"},
    :convert_options => {:large => "-strip -quality 90", 
                          :small => "-strip -quality 80", 
                          :thumb => "-strip -quality 80"}
                        }.merge(ATTACH_FILE_3_PATH)
  has_attached_file :attach_file_4, {:styles => {:large => "640x640>",:small => "200x200>",
    :thumb => "60x60>"},
    :convert_options => {:large => "-strip -quality 90", 
                          :small => "-strip -quality 80", 
                          :thumb => "-strip -quality 80"}
                        }.merge(ATTACH_FILE_4_PATH)
  has_attached_file :attach_file_5, {:styles => {:large => "640x640>",:small => "200x200>",
    :thumb => "60x60>"},
    :convert_options => {:large => "-strip -quality 90", 
                          :small => "-strip -quality 80", 
                          :thumb => "-strip -quality 80"}
                        }.merge(ATTACH_FILE_5_PATH)

validates_attachment :attach_file,:attach_file_2,:attach_file_3,:attach_file_4,:attach_file_5, size: { in: 0..10.megabytes, :message => "upload file upto 10 mb" }
#do_not_validate_attachment_file_type :attach_file
validates :invitee_id,:attach_file_1_name, presence: { :message => "This field is required." }
validates_attachment_presence :attach_file, :message => "This field is required." 
validates_uniqueness_of :invitee_id, :message => "This Invitee is already Use." 
validates_attachment_content_type :attach_file,:attach_file_2,:attach_file_3,:attach_file_4,:attach_file_5, :content_type => ["application/pdf"],:message => "please select valid format."

	def attached_url
    self.attach_file.present? ? self.attach_file.url : ''
	end

  def attachment_type
    file_type = self.attach_file_content_type.split("/").last rescue ""
    file_type
  end

end
