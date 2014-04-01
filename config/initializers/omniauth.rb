OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
	fb_id = ENV['FACEBOOK_SPEAKLOUD_TWIL_APP_ID'] || raise("Please set FACEBOOK_SPEAKLOUD_TWIL_APP_ID")
	fb_secret = ENV['FACEBOOK_SPEAKLOUD_TWIL_SECRET'] || raise("Please set FACEBOOK_SPEAKLOUD_TWIL_SECRET")
  provider :facebook, fb_id, fb_secret
end