class RemoveSequenceFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :sequence 
  end
end
