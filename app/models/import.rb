class Import < ActiveRecord::Base
  attr_accessor :event_id, :client_id
  has_attached_file :import_file,
                     {}.merge(IMPORT_STORAGE)
  validates_attachment_presence :import_file,:message => "This field is required."
  # validates_attachment :import_file, content_type: { content_type: "application/*" }

  validates_attachment_content_type :import_file, :content_type => %w(application/zip application/msword application/vnd.ms-office application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/xls application/xlsx application/octet-stream)

  default_scope { order('created_at desc') }

  def validation_errors_for_data(error_messages)
    self.errors.add(:import_file, error_messages.join("<br/>"))
  end  
end
