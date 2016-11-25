class CreateCourseProviders < ActiveRecord::Migration
  def change
    create_table :course_providers do |t|
      t.string :provider_name
      t.integer :event_id
      t.attachment :logo

      t.timestamps null: false
    end
  end
end
