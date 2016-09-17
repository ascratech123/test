class CreateMicrosites < ActiveRecord::Migration
  def change
    create_table :microsites do |t|
    	t.string  :subject_line
    	t.string  :template_type
    	t.string  :default_template
      t.string  :select_font
    	t.string  :header_image_file_name
    	t.string  :header_image_content_type
    	t.string  :header_image_file_size
    	t.string  :header_image_updated_at
    	t.string  :banner_image_file_name
    	t.string  :banner_image_content_type
    	t.string  :banner_image_file_size
    	t.string  :banner_image_updated_at
    	t.string  :logo_image_file_name
    	t.string  :logo_image_content_type
    	t.string  :logo_image_file_size
    	t.string  :logo_image_updated_at
    	t.string  :need_social_icon
    	t.string  :social_icons
    	t.string  :facebook_link
    	t.string  :google_plus_link
    	t.string  :linkedin_link
    	t.string  :twitter_link
      t.text  :body
      t.string :custom_code
      t.string  :need_registration_form
      t.string  :field1
      t.string  :field2
      t.string  :field3
      t.string  :field4
      t.string  :field5
      t.integer  :event_id
      t.text  :micro_url
    	t.string  :header_color
    	t.string  :footer_color
      t.string  :website_name

    	t.timestamps null: false
    end
  end
end
