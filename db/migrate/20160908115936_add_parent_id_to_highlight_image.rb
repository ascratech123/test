class AddParentIdToHighlightImage < ActiveRecord::Migration
  def change
    add_column :highlight_images, :parent_id, :integer
    add_index :highlight_images, :parent_id
  end
end
