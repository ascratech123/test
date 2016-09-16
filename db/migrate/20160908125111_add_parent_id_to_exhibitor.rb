class AddParentIdToExhibitor < ActiveRecord::Migration
  def change
    add_column :exhibitors, :parent_id, :integer
    add_index :exhibitors, :parent_id
  end
end
