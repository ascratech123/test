class AddCompositeIndexOnFeedbackForms < ActiveRecord::Migration
  def change
    add_index :feedback_forms, [:updated_at, :event_id, :sequence]
  end
end
