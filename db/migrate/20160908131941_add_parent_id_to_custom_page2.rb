class AddParentIdToCustomPage2 < ActiveRecord::Migration
  def change
    add_column :custom_page2s, :parent_id, :integer
    add_index :custom_page2s, :parent_id
  end
end
