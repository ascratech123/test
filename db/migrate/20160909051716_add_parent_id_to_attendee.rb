class AddParentIdToAttendee < ActiveRecord::Migration
  def change
    add_column :attendees, :parent_id, :integer
    add_index :attendees, :parent_id
  end
end
