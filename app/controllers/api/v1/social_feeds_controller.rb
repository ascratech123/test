class Api::V1::SocialFeedsController < ApplicationController

	skip_before_filter :authenticate_user
	require 'tasks/time_zone_api'

	def index
	    @event = Event.find_by_id(params[:event_id]) 
		if @event.present? or @event.facebook_social_tags.present? or @event.twitter_social_tags.present? 
			#@facebook_posts
			if @event.facebook_social_tags.present?
				@facebook_posts = get_feacebook_posts(@event.facebook_social_tags)
			else
				@facebook_posts = []
			end
		#twitter posts	
		if @event.twitter_social_tags.present?
			@twitter_posts = get_twitter_posts(@event.twitter_social_tags)
		else
			@twitter_posts = []
		end
			@total_posts = @facebook_posts + @twitter_posts
	  	@social_feeds =  @total_posts.sort_by { |hsh| hsh[:created_at] }.reverse!
	  end	
  end
end

	def get_feacebook_posts(facebook_tags)
			session[:facebook_post_date] = nil if request.format == "html"
			@posts = TimeZoneApi.get_facebook_posts(facebook_tags,session[:facebook_post_date])
			session[:facebook_post_date] = @posts["data"].last["created_time"].to_date if @posts.present? && @posts["data"].present?
			data = []
			@posts["data"].each do |post|
				hsh = {:facebook_frames =>post["id"],:created_at=>post["created_time"].to_datetime}
				data << hsh
			end if @posts["data"].present?
			@facebook_posts = data
	end	

	def get_twitter_posts(twitter_social_tags)
		@twitter_tags = twitter_social_tags.gsub(',','+OR+')	
		session[:last_twitter_id] = nil if request.format == "html"
		@twitter_posts = CLIENT.search( @twitter_tags , result_type: "recent",max_id:session[:last_twitter_id]).take(4)
		session[:last_twitter_id] = @twitter_posts.last.id-1  if @twitter_posts.present?
		@twitter_posts = @twitter_posts.sort_by{ |k, v| k.created_at}.reverse!
	  data = []
	  @twitter_posts.each do |post|
		 	@posts = TimeZoneApi.get_twitter_posts(post.url)
			twitter_data = {:twitter_frame => @posts["html"],:created_at => post.created_at}
			data << twitter_data  
		end
		@posts = data
	end	
