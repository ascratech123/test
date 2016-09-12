class CreateActivityPoints < ActiveRecord::Migration
  def change
    create_table :activity_points do |t|
    	t.string :action
    	t.integer :action_point
    	t.boolean :one_time_only
      t.datetime :start_activity_date
      t.datetime :end_activity_date
      t.datetime :start_activity_time
      t.datetime :end_activity_time

      t.timestamps null: false
    end
  end
end
