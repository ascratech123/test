class AddCompositeIndexOnCustomPage2s < ActiveRecord::Migration
  def change
    add_index :custom_page2s, [:updated_at, :event_id]
  end
end
