class AddParentIdToImage < ActiveRecord::Migration
  def change
    add_column :images, :parent_id, :integer
    add_index :images, :parent_id
  end
end
