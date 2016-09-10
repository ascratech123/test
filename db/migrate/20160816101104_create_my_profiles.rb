class CreateMyProfiles < ActiveRecord::Migration
  def change
    create_table :my_profiles do |t|
    	t.integer :event_id
    	t.text :enabled_attr
    	t.string :attr1
    	t.string :attr2
    	t.string :attr3
    	t.string :attr4
    	t.string :attr5

      t.timestamps null: false
    end
  end
end
