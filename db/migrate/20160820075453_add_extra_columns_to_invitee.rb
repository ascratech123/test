class AddExtraColumnsToInvitee < ActiveRecord::Migration
  def change
    add_column :invitees, :attr1, :text
    add_column :invitees, :attr2, :text
    add_column :invitees, :attr3, :text
    add_column :invitees, :attr4, :text
    add_column :invitees, :attr5, :text
  end
end
