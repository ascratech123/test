class AddCompIndexOnSpeakers < ActiveRecord::Migration
  def change
    add_index :speakers, [:updated_at, :event_id]
  end
end
