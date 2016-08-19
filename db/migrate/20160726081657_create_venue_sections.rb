class CreateVenueSections < ActiveRecord::Migration
  def change
    create_table :venue_sections do |t|
      t.integer :event_id
      t.string  :name
      t.string  :default_access, :default => "no"
      t.timestamps null: false
    end
  end
end
