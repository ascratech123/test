class AddDefaultToGroupings < ActiveRecord::Migration
  def change
    add_column :groupings, :default_group, :string, :default => "false"
  end
end
