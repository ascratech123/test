class AddCompositeIndexOnCustomPage3s < ActiveRecord::Migration
  def change
    add_index :custom_page3s, [:updated_at, :event_id]
  end
end
