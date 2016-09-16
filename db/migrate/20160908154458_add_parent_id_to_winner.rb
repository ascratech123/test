class AddParentIdToWinner < ActiveRecord::Migration
  def change
    add_column :winners, :parent_id, :integer
    add_index :winners, :parent_id
  end
end
