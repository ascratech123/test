class AddComIndexOnPolls < ActiveRecord::Migration
  def change
    add_index :polls, [:updated_at, :event_id, :sequence]
  end
end
