class AddParentIdToEventFeatures < ActiveRecord::Migration
  def change
    add_column :event_features, :parent_id, :integer
  end
end
