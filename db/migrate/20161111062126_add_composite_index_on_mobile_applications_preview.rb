class AddCompositeIndexOnMobileApplicationsPreview < ActiveRecord::Migration
  def change
    add_index :mobile_applications, [:preview_code, :created_at]
  end
end
