class PushPemFile < ActiveRecord::Base
  belongs_to :mobile_application

  has_attached_file :pem_file,
                    :path => "public/push_pem_files/pem_file/:id_:filename",
                    :url => ":rails_root/public/push_pem_files/pem_file/:id_:filename"

  # has_attached_file :photo,
  #                   :url => "/assets/products/:id/:style/:basename.:extension",
  #                   :path => ":rails_root/public/assets/products/:id/:style/:basename.:extension"


  before_save :rename_pem_file_name

  #validates_attachment_content_type :pem_file, :content_type => ["application/x-x509-ca-cert", "application/x-x509-ca-cert", "application/cert", "application/pem", "text/plain"]
  do_not_validate_attachment_file_type :pem_file
  validates_attachment_presence :pem_file,:message => "This field is required."
  validates :mobile_application_id, :pass_phrase, :push_url, :android_push_key, presence: { :message => "This field is required." }

  default_scope { order('created_at desc') }

  def rename_pem_file_name
    extension = File.extname(pem_file_file_name).downcase
    self.pem_file_file_name = "#{Time.now.to_i.to_s}#{extension}"
  end
end