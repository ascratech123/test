# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Event.all.each do |event|
	ActivityPoint.create! action: "favorite", action_point: 5, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "rated", action_point: 5, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "comment", action_point: 2, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "conversation post", action_point: 5, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "like", action_point: 2, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "quiz correct answer", action_point: 5, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "quiz incorrect answer", action_point: 2, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "question asked", action_point: 5, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "poll answered", action_point: 5, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "feedback given", action_point: 10, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "e_kits", action_point: 5, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "Login", action_point: 10, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "profile_pic", action_point: 5, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "page view", action_point: 5, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "played", action_point: 5, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "Add To Calender", action_point: 10, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "one_on_one", action_point: 0, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "group chat", action_point: 0, one_time_only: false, event_id: event.id
	ActivityPoint.create! action: "share", action_point: 5, one_time_only: false, event_id: event.id
end