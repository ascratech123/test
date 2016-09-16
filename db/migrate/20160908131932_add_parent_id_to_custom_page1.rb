class AddParentIdToCustomPage1 < ActiveRecord::Migration
  def change
    add_column :custom_page1s, :parent_id, :integer
    add_index :custom_page1s, :parent_id
  end
end
