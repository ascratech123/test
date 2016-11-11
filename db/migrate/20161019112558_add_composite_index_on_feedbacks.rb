class AddCompositeIndexOnFeedbacks < ActiveRecord::Migration
  def change
    add_index :feedbacks, [:updated_at, :event_id, :sequence]
  end
end
