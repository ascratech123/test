class AddFieldsToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :custom_content, :string
  	add_column :events, :copy_content, :string
  	add_column :events, :copy_event, :string  	
  end
end
