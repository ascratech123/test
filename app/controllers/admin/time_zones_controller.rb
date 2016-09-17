class Admin::TimeZonesController < ApplicationController
  
  layout 'admin'
  require 'tasks/time_zone_api'
  require 'uri'
	before_filter :authenticate_user
  
  def index
  	city_name = params[:city_name]
  	if city_name.present?
  		city_name = URI.encode(city_name)
  	  position = TimeZoneApi.get_lat_long_from_city(city_name)
	  	if position["results"].present?
	  		lat = position["results"][0]["geometry"]["location"]["lat"]
	  		lng = position["results"][0]["geometry"]["location"]["lng"]
	  		timezone_detail = TimeZoneApi.get_time_zone(lat,lng)
	  		@timezone = timezone_detail["timeZoneId"].split("/").second.titleize if timezone_detail.present?
	  		if @timezone == "Calcutta"
	  			@timezone = "Kolkata"
	  		end	
			end		
		end	
  end
end
