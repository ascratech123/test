class Image < ActiveRecord::Base
	
  belongs_to :imageable, polymorphic: true
  has_many :favorites, as: :favoritable, :dependent => :destroy
	has_attached_file :image, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(PICTURE_IMAGE_PATH)

  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"],:message => "please select valid format."
  
  before_create :set_sequence_no
  
  default_scope { order('sequence') }
  
  def image_url(style=:large)
  	style.present? ? self.image.url(style) : self.image.url
	end

  def set_sequence_no
    self.sequence = (Event.find(self.imageable_id).images.pluck(:sequence).compact.max.to_i + 1)rescue nil
  end

  def to_jq_upload
    {
      "name" => read_attribute(:image),
      "size" => image.size,
      "url" => image.url(:thumb),
      "thumbnail_url" => image.url(:thumb),
      "delete_url" => image.url(:thumb),
      "delete_type" => "DELETE" ,
      "id" => self.id
    }
  end

end
