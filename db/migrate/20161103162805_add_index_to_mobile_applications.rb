class AddIndexToMobileApplications < ActiveRecord::Migration
  def change
    add_index :mobile_applications, :preview_code
    add_index :mobile_applications, :created_at

  end
end
