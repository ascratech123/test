class AddCompositeIndexOnCustomPage5s < ActiveRecord::Migration
  def change
    add_index :custom_page5s, [:updated_at, :event_id]
  end
end
