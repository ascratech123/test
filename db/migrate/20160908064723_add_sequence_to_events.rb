class AddSequenceToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :sequence, :float
  end
end
