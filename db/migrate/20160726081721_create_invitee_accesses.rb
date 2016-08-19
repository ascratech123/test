class CreateInviteeAccesses < ActiveRecord::Migration
  def change
    create_table :invitee_accesses do |t|
      t.integer :event_id
      t.integer :invitee_id
      t.integer :venue_section_id
      t.timestamps null: false
    end
  end
end
