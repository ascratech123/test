class AddParentIdToAgendaTrack < ActiveRecord::Migration
  def change
    add_column :agenda_tracks, :parent_id, :integer
    add_index :agenda_tracks, :parent_id
  end
end
