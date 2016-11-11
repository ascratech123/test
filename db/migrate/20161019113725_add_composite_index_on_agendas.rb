class AddCompositeIndexOnAgendas < ActiveRecord::Migration
  def change
    add_index :agendas, [:updated_at, :event_id, :start_agenda_time]
  end
end
