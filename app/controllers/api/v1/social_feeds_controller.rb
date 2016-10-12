class Api::V1::SocialFeedsController < ApplicationController

	require 'tasks/time_zone_api'

	def index
    #@facebook_posts = TimeZoneApi.get_facebook_posts
	    @event = Event.find_by_id(params[:event_id])
	    @facebook_tags = @event.facebook_social_tags if @event.present? 
	    @twitter_tags = @event.twitter_social_tags if @event.present? 
		if @event.present? or @facebook_tags.present? or @twitter_tags.present? 
			#@facebook_posts
			if @facebook_tags.present?
				date = nil if request.format == "html"
				#@posts = TimeZoneApi.get_facebook_posts(date)
				@posts = HTTParty.get("https://graph.facebook.com/#{@facebook_tags}/posts?access_token=EAAEUA07UHnEBABbXziqZBHoQ5sBQBBWsE1u8WQlFrydxcB4FpxWFI5BRV786UwuTkLfVdAIYUF67ZBsEGJB2BZA3KVGkDIlKcxOA48rZA0AUszqvZCLnQbswMgyV2EhMx0wZCoNKs5kGEeApEcWcjaaaK5uVGpS2kZD&limit=4&until=#{date}")
				date = @posts["data"].last["created_time"].to_date  if @posts.present? && @posts["data"].present?
				data = []
				@posts["data"].each do |post|
					hsh = {:facebook_frames =>post["id"],:created_at=>post["created_time"].to_datetime}
					data << hsh
				end if @posts["data"].present?
				@facebook_posts = data
			else
				@facebook_posts = []	
			end	 
		#twitter details	
		if @twitter_tags.present?	
			session[:last_twitter_id] = nil if request.format == "html"
			@twitter_posts = CLIENT.search( @twitter_tags, result_type: "recent",max_id:session[:last_twitter_id]).take(4)
			session[:last_twitter_id] = @twitter_posts.last.id-1  if @twitter_posts.present?
			@twitter_posts = @twitter_posts.sort_by{ |k, v| k.created_at}.reverse!
	    data = []
	    @twitter_posts.each do |post|
	    	tweet_url = post.url
		 		@posts = TimeZoneApi.get_twitter_posts(post.url)
			  twitter_data = {}
			  twitter_data[:twitter_frame] = @posts["html"]
			  twitter_data[:created_at] = post.created_at
				data << twitter_data  
			end
			@posts = data
		else
			@posts = []
		end	
			@total_posts = @facebook_posts + @posts
	  	@social_feeds =  @total_posts.sort_by { |hsh| hsh[:created_at] }.reverse!
	  	@social_feeds = @social_feeds
	  end	
  end
end
