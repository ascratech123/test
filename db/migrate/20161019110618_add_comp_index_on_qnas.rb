class AddCompIndexOnQnas < ActiveRecord::Migration
  def change
    add_index :qnas, [:updated_at, :event_id, :created_at]
  end
end
