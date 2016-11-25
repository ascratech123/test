class CourseLecturer < ActiveRecord::Base

  has_many :courses
  has_many :lecturers

end
