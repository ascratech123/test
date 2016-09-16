class AddParentIdToFaq < ActiveRecord::Migration
  def change
    add_column :faqs, :parent_id, :integer
    add_index :faqs, :parent_id
  end
end
