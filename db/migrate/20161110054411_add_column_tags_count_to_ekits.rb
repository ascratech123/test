class AddColumnTagsCountToEkits < ActiveRecord::Migration
  def change
    add_column :e_kits, :tags_count, :integer
  end
end
