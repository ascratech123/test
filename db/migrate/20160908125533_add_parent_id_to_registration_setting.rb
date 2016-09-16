class AddParentIdToRegistrationSetting < ActiveRecord::Migration
  def change
    add_column :registration_settings, :parent_id, :integer
    add_index :registration_settings, :parent_id
  end
end
