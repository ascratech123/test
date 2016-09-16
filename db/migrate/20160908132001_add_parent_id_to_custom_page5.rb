class AddParentIdToCustomPage5 < ActiveRecord::Migration
  def change
    add_column :custom_page5s, :parent_id, :integer
    add_index :custom_page5s, :parent_id
  end
end
