class MyTravelDoc < ActiveRecord::Base
  attr_accessor :upload_files
  belongs_to :event  
  has_attached_file :my_travel_attach_doc, {}.merge(MY_TRAVEL_DOC_FILE) 
  validates_attachment_content_type :my_travel_attach_doc, :content_type => ["application/pdf"],:message => "please select valid format."
  validates_attachment :my_travel_attach_doc, size: { in: 0..10.megabytes, :message => "having size more than 10 mb" }

  Paperclip.interpolates :event_id  do |attachment, style|
    attachment.instance.event_id
  end

end
