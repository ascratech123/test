class AddColumnCopyContentButtonToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :copy_content_button, :string
  end
end
