class AddCompositeIndexOnConversations < ActiveRecord::Migration
  def change
    add_index :conversations, [:updated_at, :event_id, :status]
  end
end
