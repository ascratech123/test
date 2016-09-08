class Admin::DashboardsController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user
  
  def index
    if current_user.has_role? :db_manager
      @count = Event.with_role(:db_manager, current_user)
    end
    if current_user.has_role? :moderator
      @count = Event.with_role(:moderator, current_user)
    end
    if current_user.has_role? :event_admin
      @count = Event.with_roles(current_user.roles.pluck(:name), current_user)
    end
  end
end
