class CourseProvider < ActiveRecord::Base

  has_many :courses
  belongs_to :event
  
  has_attached_file :logo, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(COURSE_PROVIDER_LOGO_PATH)

  validates_attachment_content_type :logo, :content_type => ["image/png","image/jpg","image/jpeg"],:message => "please select valid format."
  validates_uniqueness_of :provider_name, :scope => [:event_id]
end
