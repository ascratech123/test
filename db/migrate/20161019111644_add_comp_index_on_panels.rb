class AddCompIndexOnPanels < ActiveRecord::Migration
  def change
   add_index :panels, [:updated_at, :event_id, :sequence]
  end
end
