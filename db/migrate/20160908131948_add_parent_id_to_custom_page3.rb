class AddParentIdToCustomPage3 < ActiveRecord::Migration
  def change
    add_column :custom_page3s, :parent_id, :integer
    add_index :custom_page3s, :parent_id
  end
end
