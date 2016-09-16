class AddParentIdToEmergencyExit < ActiveRecord::Migration
  def change
    add_column :emergency_exits, :parent_id, :integer
    add_index :emergency_exits, :parent_id
  end
end
