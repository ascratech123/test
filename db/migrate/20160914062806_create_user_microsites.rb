class CreateUserMicrosites < ActiveRecord::Migration
  def change
    create_table :user_microsites do |t|
    	t.string  :event_id
    	t.string  :field1
    	t.string  :field2
    	t.string  :field3
    	t.string  :field4
    	t.string  :field5

      t.timestamps null: false
    end
  end
end
