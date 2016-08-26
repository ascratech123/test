class AddColumnsForTimezoneChanges < ActiveRecord::Migration
  def change
    add_column :abouts, :created_at_with_event_timezone, :datetime
    add_column :abouts, :updated_at_with_event_timezone, :datetime
    add_column :agendas, :start_agenda_time_with_event_timezone, :datetime
    add_column :agendas, :end_agenda_time_with_event_timezone, :datetime
    add_column :analytics, :created_at_with_event_timezone, :datetime
    add_column :analytics, :updated_at_with_event_timezone, :datetime
    add_column :chats, :created_at_with_event_timezone, :datetime
    add_column :chats, :updated_at_with_event_timezone, :datetime
    add_column :conversations, :created_at_with_event_timezone, :datetime
    add_column :conversations, :updated_at_with_event_timezone, :datetime
    add_column :e_kits, :created_at_with_event_timezone, :datetime
    add_column :e_kits, :updated_at_with_event_timezone, :datetime
    add_column :faqs, :created_at_with_event_timezone, :datetime
    add_column :faqs, :updated_at_with_event_timezone, :datetime
    add_column :highlight_images, :created_at_with_event_timezone, :datetime
    add_column :highlight_images, :updated_at_with_event_timezone, :datetime
    add_column :polls, :poll_start_date_time_with_event_timezone, :datetime
    add_column :polls, :poll_end_date_time_with_event_timezone, :datetime
    add_column :qnas, :created_at_with_event_timezone, :datetime
    add_column :qnas, :updated_at_with_event_timezone, :datetime
  end
end
