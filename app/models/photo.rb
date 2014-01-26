# == Schema Information
#
# Table name: photos
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  url              :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  tweet_id         :integer
#  tweet_created_at :datetime
#

class Photo < ActiveRecord::Base
  attr_accessible :url, :user_id, :tweet_id, :tweet_created_at
  belongs_to :user
  scope :tweet_created_at_asc, where('tweet_created_at IS NOT NULL').order('tweet_created_at ASC')

  def self.twitter
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_OAUTH_TOKEN"]
      config.access_token_secret = ENV["TWITTER_OAUTH_TOKEN_SECRET"]
    end
  end

  def self.pull_tweets(user)
	 	self.twitter.user_timeline(user.twitter_handle).each do |tweet|
	    	Photo.create_photo(tweet, user)
	  end
	end

	def self.update_tweets(user)
	 	self.twitter.user_timeline(user.twitter_handle, since_id: user.photos.tweet_created_at_asc.last.tweet_id).each do |tweet|
	    Photo.create_photo(tweet, user)
	  end
	end

	def self.create_photo(tweet, user)
		unless tweet.media.empty?
	    		create!(
	    				url: tweet.attrs[:entities][:media][0][:media_url],
	    				user_id: user.id,
	    				tweet_id: tweet.id,
	    				tweet_created_at: tweet.created_at
	    		)
	    	end
	end
end
