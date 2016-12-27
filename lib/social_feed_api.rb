require 'httparty'

class SocialFeedApi

	include HTTParty
	def self.get_facebook_posts(facebook_tags,date)
		# if date == nil
		# 	facebook_data = HTTParty.get("https://graph.facebook.com/#{facebook_tags}/posts?access_token=EAAEUA07UHnEBABbXziqZBHoQ5sBQBBWsE1u8WQlFrydxcB4FpxWFI5BRV786UwuTkLfVdAIYUF67ZBsEGJB2BZA3KVGkDIlKcxOA48rZA0AUszqvZCLnQbswMgyV2EhMx0wZCoNKs5kGEeApEcWcjaaaK5uVGpS2kZD&limit=4") rescue ""
		# else	
		# 	facebook_data = HTTParty.get("https://graph.facebook.com/#{facebook_tags}/posts?access_token=EAAEUA07UHnEBABbXziqZBHoQ5sBQBBWsE1u8WQlFrydxcB4FpxWFI5BRV786UwuTkLfVdAIYUF67ZBsEGJB2BZA3KVGkDIlKcxOA48rZA0AUszqvZCLnQbswMgyV2EhMx0wZCoNKs5kGEeApEcWcjaaaK5uVGpS2kZD&limit=4&until=#{date}") rescue ""
		# end	
			facebook_data = HTTParty.get("https://graph.facebook.com/#{facebook_tags}/posts?access_token=EAAJLHgicUhoBAJIjRFmhAX4Kfskd1rhgisjpCMi5mXZA7vP0ndpFl8KZCGH5BI9a12VbgsVAEwbnHVQ2bXZCrcGWcLZA3SJ4x1ub2OdZB5qE4G2MPHOOZAHmLxtNHxmzaer1L8NENOmepiAZBTVViaexYQbpU73EdPaB7Oisqk9UQZDZDa&limit=20&until=#{date}") rescue ""
	end	

	def self.get_twitter_posts(url)
		enconded_url = URI.encode("https://publish.twitter.com/oembed?url=#{url}")
		HTTParty.get(enconded_url)
	end
end
