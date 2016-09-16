class AddParentIdToCustomPage4 < ActiveRecord::Migration
  def change
    add_column :custom_page4s, :parent_id, :integer
    add_index :custom_page4s, :parent_id
  end
end
