class AddParentIdToInvitee < ActiveRecord::Migration
  def change
    add_column :invitees, :parent_id, :integer
    add_index :invitees, :parent_id
  end
end
