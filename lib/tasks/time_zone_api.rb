require 'httparty'

class TimeZoneApi

	include HTTParty

	def self.get_lat_long_from_city(city_name,country_name)
		address = "#{country_name}" "+" "#{city_name}"
		HTTParty.get "http://maps.googleapis.com/maps/api/geocode/json?address=city:#{city_name},country:#{country_name}"
	end

	def self.get_time_zone(lat,lng,timestamp)
		HTTParty.get "https://maps.googleapis.com/maps/api/timezone/json?location=#{lat},#{lng}&timestamp=#{timestamp}"
	end

	def self.get_facebook_posts(facebook_tags,date)
		if date == nil
			HTTParty.get("https://graph.facebook.com/#{facebook_tags}/posts?access_token=EAAEUA07UHnEBABbXziqZBHoQ5sBQBBWsE1u8WQlFrydxcB4FpxWFI5BRV786UwuTkLfVdAIYUF67ZBsEGJB2BZA3KVGkDIlKcxOA48rZA0AUszqvZCLnQbswMgyV2EhMx0wZCoNKs5kGEeApEcWcjaaaK5uVGpS2kZD&limit=4")
		else	
			HTTParty.get("https://graph.facebook.com/#{facebook_tags}/posts?access_token=EAAEUA07UHnEBABbXziqZBHoQ5sBQBBWsE1u8WQlFrydxcB4FpxWFI5BRV786UwuTkLfVdAIYUF67ZBsEGJB2BZA3KVGkDIlKcxOA48rZA0AUszqvZCLnQbswMgyV2EhMx0wZCoNKs5kGEeApEcWcjaaaK5uVGpS2kZD&limit=4&until=#{date}")
		end
	end	

	def self.get_twitter_posts(url)
		enconded_url = URI.encode("https://publish.twitter.com/oembed?url=#{url}")
		HTTParty.get(enconded_url)
	end

end