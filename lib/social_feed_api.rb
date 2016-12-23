require 'httparty'

class SocialFeedApi

	include HTTParty
	def self.get_facebook_posts(facebook_tags)
		# if date == nil
		# 	facebook_data = HTTParty.get("https://graph.facebook.com/#{facebook_tags}/posts?access_token=EAAEUA07UHnEBABbXziqZBHoQ5sBQBBWsE1u8WQlFrydxcB4FpxWFI5BRV786UwuTkLfVdAIYUF67ZBsEGJB2BZA3KVGkDIlKcxOA48rZA0AUszqvZCLnQbswMgyV2EhMx0wZCoNKs5kGEeApEcWcjaaaK5uVGpS2kZD&limit=4") rescue ""
		# else	
		# 	facebook_data = HTTParty.get("https://graph.facebook.com/#{facebook_tags}/posts?access_token=EAAEUA07UHnEBABbXziqZBHoQ5sBQBBWsE1u8WQlFrydxcB4FpxWFI5BRV786UwuTkLfVdAIYUF67ZBsEGJB2BZA3KVGkDIlKcxOA48rZA0AUszqvZCLnQbswMgyV2EhMx0wZCoNKs5kGEeApEcWcjaaaK5uVGpS2kZD&limit=4&until=#{date}") rescue ""
		# end
			facebook_data = HTTParty.get("https://graph.facebook.com/#{facebook_tags}/posts?access_token=EAACEdEose0cBADLHmNiZCnHazZBvX1pTi31msLtMBEZCYJsJIuwlJJFBHnr4HCRyboUVoicZCukZB6Ezbf47q90b3DZBFtWeZBiYozuZCqJRzJdHZBSsUOFtgqZB8EAMfkp1xWrfpaZC3Xb46rQtIcbpKplQ7rDyPrGiuuOzNENI11qZCgZDZD&limit=20") rescue ""
	end	

	def self.get_twitter_posts(url)
		enconded_url = URI.encode("https://publish.twitter.com/oembed?url=#{url}")
		HTTParty.get(enconded_url)
	end

	def self.get_own_instgram_posts(event,user_id)
		#if max_insta_id.blank?
		instagram_data = HTTParty.get("https://api.instagram.com/v1/users/#{user_id}/media/recent?count=8&access_token=#{event.instagram_access_token}") rescue ""
		# else
		# instagram_data = HTTParty.get("https://api.instagram.com/v1/users/#{user_id}/media/recent?count=10&access_token=#{event.instagram_access_token}") rescue ""
		# end	
	end

end
