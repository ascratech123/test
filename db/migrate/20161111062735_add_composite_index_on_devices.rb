class AddCompositeIndexOnDevices < ActiveRecord::Migration
  def change
    add_index :devices, [:token, :id]
  end
end
