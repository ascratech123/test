class AddCompositeIndexOnFeedbacks < ActiveRecord::Migration
  def change
    add_index :feedbacks, [:event_id, :sequence]
  end
end
