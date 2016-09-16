class AddParentIdToGrouping < ActiveRecord::Migration
  def change
    add_column :groupings, :parent_id, :integer
    add_index :groupings, :parent_id
  end
end
