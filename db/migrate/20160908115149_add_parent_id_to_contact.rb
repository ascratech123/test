class AddParentIdToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :parent_id, :integer
    add_index :contacts, :parent_id
  end
end
