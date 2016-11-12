class AddCompositeIndexOnUserFeedbacks < ActiveRecord::Migration
  def change
    add_index :user_feedbacks, [:feedback_id, :updated_at, :created_at], :name => "index_user_feedbacks_on_feedback_id_updated_created"
  end
end
