class AddParentIdToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :parent_id, :integer
    add_index :registrations, :parent_id
  end
end
