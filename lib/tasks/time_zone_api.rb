require 'httparty'

class TimeZoneApi

	include HTTParty

	def self.get_lat_long_from_city(city_name,country_name)
		address = "#{country_name}" "+" "#{city_name}"
		HTTParty.get "http://maps.googleapis.com/maps/api/geocode/json?address=city:#{city_name},country:#{country_name}"
		#HTTParty.get "http://maps.googleapis.com/maps/api/geocode/json?address=#{address}"
	end

	def self.get_time_zone(lat,lng)
		HTTParty.get "https://maps.googleapis.com/maps/api/timezone/json?location=#{lat},#{lng}&timestamp=1458000000"
	end
end