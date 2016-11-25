class CreateCourseTags < ActiveRecord::Migration
  def change
    create_table :course_tags do |t|
      t.integer :course_id
      t.string :tag_name

      t.timestamps null: false
    end
  end
end
