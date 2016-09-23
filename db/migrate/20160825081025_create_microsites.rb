class CreateMicrosites < ActiveRecord::Migration
  def change
    create_table :microsites do |t|
    	t.integer  :campaign_id
      t.integer  :client_id
      t.string   :subject_line
      t.datetime :microsite_broadcast_time
      t.string   :template_type
      t.text     :custom_code
      t.string   :default_template
      t.string   :microsite_broadcast_value
      t.string   :header_image_file_name
      t.string   :header_image_content_type
      t.integer  :header_image_file_size
      t.datetime :header_image_updated_at
      t.string   :banner_image_file_name
      t.string   :banner_image_content_type
      t.integer  :banner_image_file_size
      t.datetime :banner_image_updated_at
      t.string   :logo_image_file_name
      t.string   :logo_image_content_type
      t.integer  :logo_image_file_size
      t.datetime :logo_image_updated_at
      t.text     :body
      t.string   :sent
      t.string   :group_type
      t.string   :group_id
      t.string   :database_email_field
      t.string   :flag,:default => "0"
      t.string   :flag
      t.string   :need_social_icon
      t.string   :need_registration_form
      t.string   :social_icons
      t.string   :email_sent
      t.string   :registered
      t.string   :registration_approved
      t.string   :confirmed
      t.string   :attended
      t.string   :email_opened
      t.string   :sent
      t.string   :facebook_link
      t.string   :google_plus_link
      t.string   :linkedin_link
      t.string   :twitter_link
      t.string   :header_color
      t.string   :footer_color
      t.string   :sender_email
      t.string   :event_timezone
      t.string   :full_name
      t.string   :email
      t.string   :mobile
      t.string   :city

      t.timestamps null: false
    end
  end
end