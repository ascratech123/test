class Admin::TimeZonesController < ApplicationController
  
  layout 'admin'
  require 'tasks/time_zone_api'
  require 'uri'
	before_filter :authenticate_user
  
  def index
  	city_name = params[:city_name]
  	country_name = params[:country_name]
  	if city_name.present? && country_name.present?
  		city_name = URI.encode(city_name)
  		country_name = URI.encode(country_name)
  	  position = TimeZoneApi.get_lat_long_from_city(city_name,country_name)
	  	if position["results"].present?
	  		lat = position["results"][0]["geometry"]["location"]["lat"]
	  		lng = position["results"][0]["geometry"]["location"]["lng"]
	  		timezone_detail = TimeZoneApi.get_time_zone(lat,lng)
	  		@timezone = timezone_detail["timeZoneId"].split("/").second.titleize if timezone_detail.present?
	  		r_timezone = ActiveSupport::TimeZone.all.sort_by(&:name).map{|e| e.name}
	  		
	  		if r_timezone.include?(ActiveSupport::TimeZone[timezone_detail["rawOffset"]].name)
	  			@timezone = ActiveSupport::TimeZone[timezone_detail["rawOffset"]].name
				elsif r_timezone.include?(@timezone)
	  			@timezone
				end

				signle_timezone = ActiveSupport::TimeZone.all.sort_by(&:name).map{|e| ["GMT#{e.formatted_offset}", e.name]}
				timezone_data = signle_timezone.select{ |a| a[1] == @timezone}
				if timezone_data.present?
					@timezone = timezone_data.first[0]
				end		
			end		
		end	
  end
end
