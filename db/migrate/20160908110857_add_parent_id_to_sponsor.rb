class AddParentIdToSponsor < ActiveRecord::Migration
  def change
    add_column :sponsors, :parent_id, :integer
    add_index :sponsors, :parent_id
  end
end
