class RenameColumnsInCourses < ActiveRecord::Migration
  def change
    rename_column :courses, :lecturer_ids, :speaker_ids
    rename_column :courses, :lecturer_names, :speaker_names
    rename_column :courses, :all_lecturer_names, :all_speaker_names
  end
end
