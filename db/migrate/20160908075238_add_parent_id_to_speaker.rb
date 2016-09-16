class AddParentIdToSpeaker < ActiveRecord::Migration
  def change
    add_column :speakers, :parent_id, :integer
    add_index :speakers, :parent_id
  end
end
