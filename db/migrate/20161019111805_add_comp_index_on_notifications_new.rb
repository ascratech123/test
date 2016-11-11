class AddCompIndexOnNotificationsNew < ActiveRecord::Migration
  def change
    add_index :notifications, [:updated_at, :event_id, :pushed, :show_on_notification_screen, :created_at], :name => "index_noti_on_updtd_at_event_id_pushed_show_on_noti_crtd_at"
  end
end
