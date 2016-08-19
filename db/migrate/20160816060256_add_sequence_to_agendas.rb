class AddSequenceToAgendas < ActiveRecord::Migration
  def change
  	add_column :agendas, :sequence, :integer
  end
end
