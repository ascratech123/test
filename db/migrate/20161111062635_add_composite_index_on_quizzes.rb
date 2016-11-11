class AddCompositeIndexOnQuizzes < ActiveRecord::Migration
  def change
    add_index :quizzes, [:event_id, :sequence]
  end
end
