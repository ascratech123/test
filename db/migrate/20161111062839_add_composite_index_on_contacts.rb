class AddCompositeIndexOnContacts < ActiveRecord::Migration
  def change
    add_index :contacts, [:updated_at, :event_id, :created_at]
  end
end
