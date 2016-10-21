require 'httparty'

class SocialFeedApi

	include HTTParty
	def self.get_facebook_posts(facebook_tags,date)
		# if date == nil
		# 	facebook_data = HTTParty.get("https://graph.facebook.com/#{facebook_tags}/posts?access_token=EAAEUA07UHnEBABbXziqZBHoQ5sBQBBWsE1u8WQlFrydxcB4FpxWFI5BRV786UwuTkLfVdAIYUF67ZBsEGJB2BZA3KVGkDIlKcxOA48rZA0AUszqvZCLnQbswMgyV2EhMx0wZCoNKs5kGEeApEcWcjaaaK5uVGpS2kZD&limit=4") rescue ""
		# else	
		# 	facebook_data = HTTParty.get("https://graph.facebook.com/#{facebook_tags}/posts?access_token=EAAEUA07UHnEBABbXziqZBHoQ5sBQBBWsE1u8WQlFrydxcB4FpxWFI5BRV786UwuTkLfVdAIYUF67ZBsEGJB2BZA3KVGkDIlKcxOA48rZA0AUszqvZCLnQbswMgyV2EhMx0wZCoNKs5kGEeApEcWcjaaaK5uVGpS2kZD&limit=4&until=#{date}") rescue ""
		# end	
			facebook_data = HTTParty.get("https://graph.facebook.com/#{facebook_tags}/posts?access_token=EAAEUA07UHnEBABbXziqZBHoQ5sBQBBWsE1u8WQlFrydxcB4FpxWFI5BRV786UwuTkLfVdAIYUF67ZBsEGJB2BZA3KVGkDIlKcxOA48rZA0AUszqvZCLnQbswMgyV2EhMx0wZCoNKs5kGEeApEcWcjaaaK5uVGpS2kZD&limit=4&until=#{date}") rescue ""
	end	

	def self.get_twitter_posts(url)
		enconded_url = URI.encode("https://publish.twitter.com/oembed?url=#{url}")
		HTTParty.get(enconded_url)
	end

	def self.get_all_instagram_posts(token,hash_tag)
		instagram_data = HTTParty.get("https://api.instagram.com/v1/tags/#{hash_tag}/media/recent?&access_token=#{token}") rescue ""
	end

	def self.get_own_instgram_posts(event)
		user_details = HTTParty.get("https://api.instagram.com/v1/users/self/?access_token=#{event.instagram_access_token}")
		user_id = user_details["data"]["id"] if user_details.present?
		instagram_data = HTTParty.get("https://api.instagram.com/v1/users/#{user_id}/media/recent/?access_token=#{event.instagram_access_token}") rescue ""
	end	
end
