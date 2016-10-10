class RenameColumnInPolls < ActiveRecord::Migration
  def change
  	rename_column :polls, :option10, :option010
  end
end
