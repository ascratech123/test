class AddCompositeIndexOnCustomPage1s < ActiveRecord::Migration
  def change
    add_index :custom_page1s, [:updated_at, :event_id]
  end
end
