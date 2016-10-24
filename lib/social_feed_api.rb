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

	def self.get_own_instgram_posts(event,max_insta_id,user_id)
		if max_insta_id.blank?
		instagram_data = HTTParty.get("https://api.instagram.com/v1/users/#{user_id}/media/recent?count=2&access_token=#{event.instagram_access_token}") rescue ""
		else
		instagram_data = HTTParty.get("https://api.instagram.com/v1/users/#{user_id}/media/recent?count=2&max_id=#{max_insta_id}&access_token=#{event.instagram_access_token}") rescue ""
		end	
	end

end
