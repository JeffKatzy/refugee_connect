require 'spec_helper'

describe 'Appointments' do
	Capybara.current_driver = :selenium
	describe 'Get /' do

		it 'displays a register link', js: true do
			User.delete_all
			user_one = FactoryGirl.create(:tutee_available)
			visit root_path
			click_link('Register')
			page.choose('role_tutor')
			fill_in_user_info
	    select('2', :from => 'How many sessions do you want to teach per week?')
	    add_times_available
			click_on('Create User')
			check '_match_id_'
			click_on 'Sign up for classes'
			page.should have_content 'Bob'
			page.should have_content '01:00PM on Sunday'
			Appointment.last.scheduled_for.
			in_time_zone('Eastern Time (US & Canada)').
			strftime("%I:%M%p on %As").should eq "01:00PM on Sundays"
			date = DateTime.new 2013,9,8,17,00,00
			Timecop.travel(date)
			Appointment.batch_for_this_hour.should eq [Appointment.last]
			ReminderText.begin_session
			visit '/text_from_user/+12154997415/Go'
			Timecop.return
		end

		pending 'it should autoformat cell phone numbers' do
			#1. +91 for refugees
			#2. +1 for tutors
			#3 remove all dashes
			#4. show this in a form helper
		end
	end

	def fill_in_user_info
		fill_in('Name', :with => 'Bob')
    fill_in('Email', :with => 'bob@gmail.com')
    fill_in('Cell number', :with => '+12154997415')
    fill_in('Password', :with => 'hello')
    fill_in('Password confirmation', :with => 'hello')
  end

  def add_times_available
		click_link('Add a time available')
		page.select('Monday', from: 'Day open')
		page.select('3 pm', from: 'Time open')
		click_link('Add a time available')
  end
end

# 1. Need to have it so that it creates multiple availabilities
# 2. Need to check the availabilities, so 
# that it would only match if there is actually an appointment 
# available at that time
# 3. Change the seed file so that it adds people in the pm
# 4. Make sure that the time zones workout for both users and tutees
# 5. Write a spec that tests the signup of each of them and matching