class AddParentIdToMobileApplication < ActiveRecord::Migration
  def change
    add_column :mobile_applications, :parent_id, :integer
    add_index :mobile_applications, :parent_id
  end
end
