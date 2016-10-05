class Admin::NotificationActionChangesController < ApplicationController

  def index
    if params[:feature_name].present?
      feature_name = params[:feature_name].downcase.pluralize if params[:feature_name] != "E-Kit"
      feature_name = "e_kits" if params[:feature_name] == "E-Kit"
      event = Event.find(params[:event_id])
      if ["speakers","polls","quizzes","agendas","e_kits"].include? feature_name
        @associated_data = instance_variable_set("@"+feature_name, event.send(feature_name))
      end
    end
  end
end
