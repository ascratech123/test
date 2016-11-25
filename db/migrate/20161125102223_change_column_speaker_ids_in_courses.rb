class ChangeColumnSpeakerIdsInCourses < ActiveRecord::Migration
  def change
	change_column :courses, :speaker_ids, :string
  end
end
