class AddColumnsToCourses < ActiveRecord::Migration
  def change
	add_column :courses, :speaker_ids, :integer
	add_column :courses, :speaker_names, :string
	add_column :courses, :all_speaker_names, :text
  end
end
