require 'httparty'

class TimeZoneApi

	include HTTParty

	def self.get_lat_long_from_city(city_name)
		HTTParty.get "http://maps.googleapis.com/maps/api/geocode/json?address=#{city_name}"
	end

	def self.get_time_zone(lat,lng)
		HTTParty.get "https://maps.googleapis.com/maps/api/timezone/json?location=#{lat},#{lng}&timestamp=1458000000"
	end
end