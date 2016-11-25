class AddColumnCourseProviderIdToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :course_provider_id, :integer
  end
end
