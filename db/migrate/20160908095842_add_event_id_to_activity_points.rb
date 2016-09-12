class AddEventIdToActivityPoints < ActiveRecord::Migration
  def change
  	add_column :activity_points, :event_id, :integer
  end
end
