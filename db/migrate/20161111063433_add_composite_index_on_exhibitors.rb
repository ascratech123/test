class AddCompositeIndexOnExhibitors < ActiveRecord::Migration
  def change
    add_index :exhibitors, [:updated_at, :event_id, :sequence]
  end
end
