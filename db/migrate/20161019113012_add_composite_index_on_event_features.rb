class AddCompositeIndexOnEventFeatures < ActiveRecord::Migration
  def change
    add_index :event_features, [:updated_at, :event_id, :sequence]

  end
end
