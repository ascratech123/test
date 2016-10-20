class CreateMyTravelDocs < ActiveRecord::Migration
  def change
    create_table :my_travel_docs do |t|
      t.integer :event_id
      t.attachment :my_travel_attach_doc
      t.timestamps null: false
    end
  end
end
