# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
set :output, "log/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
#every 1.minute do
#  runner "Notification.push_notification_time_basis", :environment => :staging
#end

# Learn more: http://github.com/javan/whenever

every 60.seconds do
  runner "User.change_status_for_super_admin", :environment => :staging
end

every 1.minutes do
  runner "Notification.push_notification_time_basis", :environment => :staging
end

every 5.minutes do
  runner "Event.set_event_category", :environment => :staging
end

every 30.minutes do
  runner "Edm.send_email_time_basis", :environment => :staging
end
