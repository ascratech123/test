class AddParentIdToInviteeStructure < ActiveRecord::Migration
  def change
    add_column :invitee_structures, :parent_id, :integer
    add_index :invitee_structures, :parent_id
  end
end
