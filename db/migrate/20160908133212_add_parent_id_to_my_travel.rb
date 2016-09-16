class AddParentIdToMyTravel < ActiveRecord::Migration
  def change
    add_column :my_travels, :parent_id, :integer
    add_index :my_travels, :parent_id
  end
end
