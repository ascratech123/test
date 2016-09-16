class AddParentIdToInviteeGroup < ActiveRecord::Migration
  def change
    add_column :invitee_groups, :parent_id, :integer
    add_index :invitee_groups, :parent_id
  end
end
