class AddCompositeIndexOnCustomPage4s < ActiveRecord::Migration
  def change
    add_index :custom_page4s, [:updated_at, :event_id]
  end
end
