class AddColumnCourseIdsToSpeakers < ActiveRecord::Migration
  def change
    add_column :speakers, :course_ids, :string
  end
end
