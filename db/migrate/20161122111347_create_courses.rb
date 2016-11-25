class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :title
      t.string :course_type
      t.string :code
      t.string :venue
      t.string :duration
      t.datetime :start_time
      t.datetime :end_time
      t.float :price
      t.string :offers
      t.string :hours_per_day
      t.integer :event_id

      t.timestamps null: false
    end
  end
end
