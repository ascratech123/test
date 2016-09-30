class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
    	t.integer :event_id
    	t.string :venue

      t.timestamps null: false
    end
  end
end
