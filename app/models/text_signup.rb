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
  attr_accessible :status, :days_available, :day_missing_time
  attr_accessor :body
  belongs_to :user
  after_initialize :set_body

  def set_body
  	@body = ""
  end

  def weekday
  	['unavailable','Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
  end

  def times_open_tutee
  	["7:30 am", "8:30 am", "9:30 am"]
  end

  def times_open_tutor
  	["9:00 pm", "10:00 pm", "11:00 pm"]
  end

  def navigate_signup(text)
  	if self.status.to_s.empty?
  		initialize_user(text)
  	elsif self.status == 'user_initialized'
  		request_name
  	elsif self.status == 'user_name_requested'
  		attempt_to_find_name(text)
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
  	elsif self.status == 'twitter_signup_requested'
  		attempt_to_find_twitter_name(text)
  	else
  		puts 'No matches'
  	end
  end

  def set_user_time_zone_and_role
  	user = self.user
  	if user.location.state == 'New York'
  		user.time_zone = 'America/New_York'
  	elsif user.location.country == 'India'
  		user.time_zone = 'New Delhi'
  	else
  		user.set_time_zone_from_number
  	end
  	user.save
  end

  def day_missing_time
  	if days_available
  		number = days_available.first.to_i
  		weekday[number]
  	end
  end

  def initialize_user(text)
  	user = User.create(password: SecureRandom.hex(9), cell_number: text.incoming_number)
	  location = user.build_location(city: text.city, state: text.state, zip: text.zip)
	  self.user = user
	  self.save
	  set_user_time_zone_and_role
	  user.save
	  self.status = 'user_initialized'
	  self.save
	  body = "Welcome to SpeakLoud!"
	  attempt_to_find_name(text)
	  navigate_signup(text)
	end

	def attempt_to_find_name(text)
		if text.body.downcase.match(/name/).nil?
			@body = "Sorry, we couldn't understand that.  Please tell us your name by first typing the word name followed by your name.\n"
		  TextToUser.deliver(user, @body)
		else
		  find_name(text)
		end
	end

	
	def find_name(text)
  	user.name = text.body.downcase.split(/name/).delete_if(&:empty?).join(" ").split.map(&:capitalize).join(" ")
	  user.save
	  self.status = 'user_with_name'
	  self.save
  end

	def request_name
		@body += "Tell us your name by typing the word name followed by your name.\n For example name Jeff."
		TextToUser.deliver(user, @body)
		self.status = 'user_name_requested'
		self.save
	end

	def request_class_days
		@body = "Thanks!  When are you available?\n 1. Mon 2. Tues 3. Wednes 4. Thurs 5. Fri \n
    For example type 1, 2 for Monday and Tuesday."
    TextToUser.deliver(user, @body)
    self.status = 'class_days_requested'
    self.save
	end

	def set_days_available(text)
		self.days_available = text.body.gsub(/\D/, '')
		if self.days_available.empty?
			@body = "Sorry, when are you are available? \n 1. Monday \n 2. Tuesday \n 3. Wednesday \n 4. Thursday \n 5. Friday
	    For example type 1, 2 for Monday and Tuesday."
			TextToUser.deliver(user, @body)
		else
			self.status = 'class_days_set'
			self.save
			navigate_signup(text)
		end
	end

	def available_times
		if self.user.role == 'tutor'
			times_open_tutor
		else
			times_open_tutee
		end
	end

	def request_time_for_day(day_missing_time)
		available_times
		@body += "What time on #{day_missing_time} are you available? Are you available at #{available_times.join(" ")}?"
		TextToUser.deliver(user, @body)
		self.status = 'class_time_requested'
		self.save
	end

	def look_for_time(text)
		if text.body.match(/[123]/).present? && self.days_available.present?
			time = available_times[text.body.to_i]
			Opening.create(user_id: text.user.id, day_open: day_missing_time, time_open: time)
			@body += "Great! You now have a class set for #{day_missing_time}.  "
			self.days_available = self.days_available[1..-1]
			self.save
			puts "the number of days now available are #{self.days_available}, version 2"
			self.status = 'class_days_set'
			self.save
			navigate_signup(text)
		else
			@body = "Please enter a valid time for #{day_missing_time}.  "
			request_time_for_day(day_missing_time)
		end
	end

	def request_twitter_signup
		user = self.user
		puts "#{self.body}"
		self.body = "Now signup for twitter.  Its easy.  Text the word 'START' to the shortened number 53000.  When twitter gives you a username, send that to us and you are set."
		TextToUser.deliver(user, @body)
		self.status = 'twitter_signup_requested'
		self.save
	end

	def attempt_to_find_twitter_name(text)
		puts "In attempt to find twitter name"
		if text.body.downcase.match(/twitter/).nil?
			@body = "Sorry, please enter your name by first typing the word TWITTER followed by your username.\n"
		  TextToUser.deliver(user, @body)
		else
			puts "twitter name not nil"
		  find_twitter_name(text)
		end
	end

	def find_twitter_name(text)
		puts "In find twitter name"
		user.twitter_handle = text.body.downcase.split(/twitter/).delete_if(&:empty?).join(" ").split.join(" ")
		user.save
		@body = "You are all done! Congrats and we look forward to your first class!"
		TextToUser.deliver(user, @body)
		self.status = 'complete'
		self.save
	end
end
