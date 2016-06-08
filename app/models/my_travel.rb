class MyTravel < ActiveRecord::Base
  belongs_to :event
  belongs_to :invitee
  has_attached_file :attach_file, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(ATTACH_FILE_PATH)

validates_attachment :attach_file, size: { in: 0..10.megabytes, :message => "upload file upto 10 mb" }
#do_not_validate_attachment_file_type :attach_file
validates :invitee_id, presence: { :message => "This field is required." }
validates_attachment_presence :attach_file, :message => "This field is required." 
validates_uniqueness_of :invitee_id
validates_attachment_content_type :attach_file, :content_type => ["application/pdf"],:message => "please select valid format."

	def attached_url
    self.attach_file.present? ? self.attach_file.url : ''
	end

  def attachment_type
    file_type = self.attach_file_content_type.split("/").last rescue ""
    file_type
  end

end
