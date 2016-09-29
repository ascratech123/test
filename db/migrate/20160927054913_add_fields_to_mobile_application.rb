class AddFieldsToMobileApplication < ActiveRecord::Migration
  def change
  	add_column :mobile_applications, :choose_home_page, :string
  	add_column :mobile_applications, :home_page_event_id, :integer
  end
end
