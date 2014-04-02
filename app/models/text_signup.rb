# == Schema Information
#
# Table name: text_signups
#
#  id               :integer          not null, primary key
#  status           :string(255)
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  days_available   :string(255)
#  day_missing_time :string(255)
#

class TextSignup < ActiveRecord::Base
  attr_accessible :status, :user_id, :city, :state, :zip
  attr_accessor :body
  belongs_to :user
  after_initialize :set_body

  def set_body
  	@body = ""
  end

  def weekday
  	['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
  end

  def times_open
  	["7:30 am", "8:30 am", "9:30 am"]
  end

  def set_user_time_zone
  	user = self.user
  	if user.location.state == 'New York'
  		user.time_zone = 'America/New_York'
  	elsif user.location.country == 'India'
  		user.time_zone = 'New Delhi'
  	end
  	user.save
  end

  def day_missing_time
  	if days_available
  		number = days_available.first.to_i
  		weekday[number]
  	end
  end

  def navigate_signup(text)
  	if self.status.to_s.empty?
  		register(text)
  	elsif self.status == 'user_initialized'
  		request_name
  	elsif self.status == 'user_name_requested'
  		attempt_to_find_name
  	elsif self.status == 'user_with_name'
  		request_class_days
  	elsif self.status ==  'class_days_requested'
  		set_days_available(text)
  	elsif (self.status == 'class_days_set' && self.days_available.present?)
  		request_time_for_day(self.day_missing_time)
  	elsif self.status == 'class_time_requested'
  		look_for_time(text)
  	elsif (self.status == 'class_days_set' && !self.days_available.present?)
  		request_twitter_signup
  	else
  		puts 'No matches'
  	end
  end

  def initialize_user
  	user = User.create(password: SecureRandom.hex(9), cell_number: text.incoming_number)
	  location = user.build_location(city: text.city, state: text.state, zip: text.zip)
	  self.status = 'user_without_name'
	  self.user = user
	  self.save
	  set_user_time_zone
	  user.save
	end

  def register(text)
  	initialize_user
  	self.state = 'user_initialized'
  	body = "Welcome to SpeakLoud!"
	  attempt_to_find_name
	end

	def attempt_to_find_name
		if text.body.downcase.match(/name/).nil?  
		  navigate_signup(text)
		else
		  find_name
		end
	end

	def find_name
  	user.name = text.body.downcase.split(/name/).delete_if(&:empty?).join(" ").split.map(&:capitalize).join(" ")
	  user.save
	  self.status = 'user_with_name'
	  self.save
  end

	def request_name
		@body += "Tell us your name by testing the word name followed by your name.\n For example name Jeff."
		TextToUser.deliver(user, @body)
		self.status = 'user_name_requested'
	end

	def request_class_days
		@body = "Thanks! You are now signed up with your name.  Which day are you available?\n
	    1. Monday \n 2. Tuesday \n 3. Wednesday \n 4. Thursday \n 5. Friday \n
	    For example type 1, 2 if you are available on Monday and Tuesday."
	    TextToUser.deliver(user, @body)
	    self.status = 'class_days_requested'
	end

	def set_days_available(text)
		self.days_available = text.body.gsub(/\D/, '')
		if self.days_available.empty?
			@body = "Sorry, we couldn't understand that.  Please tell us which days you are available.\n
			1. Monday \n 2. Tuesday \n 3. Wednesday \n 4. Thursday \n 5. Friday \n
	    For example type 1, 2 if you are available on Monday and Tuesday."
			TextToUser.deliver(user, @body)
		else
			self.status = 'class_days_set'
			self.save
		end
	end

	def request_time_for_day(day_missing_time)
		@body += "What time on #{day_missing_time} are you available? Are you available at 7:30 am, 8:30 am or 9:30 am?"
		TextToUser.deliver(user, @body)
		self.status = 'class_time_requested'
		self.save
	end

	def look_for_time(text)
		if text.body.match(/[123]/).present?
			time = times_open[text.body.to_i]
			Opening.create(user_id: text.user.id, day_open: day_missing_time, time_open: time)
			@body += "Great! You now have a class set for #{day_missing_time}.  "
			self.days_available[0] = ''
			self.save
			if days_available.present?
				self.status = 'class_days_set'
				self.save
				navigate_signup(text)
			end
		else
			@body = "Please enter a valid time for #{day_missing_time}.  "
			request_time_for_day(day_missing_time)
		end
	end

	def request_twitter_signup
		user = self.user
		self.body += "Now to send pictures to us you must first sign up for twitter.  Don't worry, its very easy.  Just text the word 'START' to the shortened number 53000.  When twitter gives you your username, send that into us and you are all set."
		TextToUser.deliver(user, @body)
	end
end
