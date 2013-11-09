client = Twitter::Client.new do |config|
  config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
  config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
  config.access_token        = ENV["TWITTER_OAUTH_TOKEN"]
  config.access_token_secret = ENV["TWITTER_OAUTH_TOKEN_SECRET"]
end

# Twitter.user_timeline("Fascinatingpics").
# first.attrs[:entities][:media].first[:media_url]

#Pull the id of each tweet, and pull the id of each user
#And pull the picture