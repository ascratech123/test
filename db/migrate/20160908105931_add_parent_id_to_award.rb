class AddParentIdToAward < ActiveRecord::Migration
  def change
    add_column :awards, :parent_id, :integer
    add_index :awards, :parent_id
  end
end
