class AddParentIdToFeedback < ActiveRecord::Migration
  def change
    add_column :feedbacks, :parent_id, :integer
    add_index :feedbacks, :parent_id
  end
end
