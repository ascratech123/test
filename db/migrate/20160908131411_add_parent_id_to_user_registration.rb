class AddParentIdToUserRegistration < ActiveRecord::Migration
  def change
    add_column :user_registrations, :parent_id, :integer
    add_index :user_registrations, :parent_id
  end
end
