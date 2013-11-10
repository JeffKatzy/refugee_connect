require 'spec_helper'

describe 'Users' do
	describe 'Get /' do
		it 'displays a register link' do
			visit root_path
			page.should have_link('Register')
		end
	end

	describe 'GET /users/new' do
	  it 'displays the create users button', :js => true do
	    visit root_path
	    click_link('Register')
	    page.should have_link('I am a tutor')
	    page.should have_link('I am a tutee')
	  end
	end

	describe 'POST /user' do
  	it 'creates a new user', :js => true do
  		visit root_path
	    click_link('Register')
	    click_link('I am a tutor')
	    fill_in_user_info
	    click_link('Add a time available')
	    click_button('Create User')

	    expect(User.last.name).to eq 'Bob'
	    expect(User.last.email).to eq 'bob@gmail.com'
	    expect(User.last.cell_number).to eq '12154997415'
	    expect(User.last.openings.first.day_open).to eq 'Sunday'
	    expect(User.last.openings.first.time_open).to eq "9 pm"
	    expect(User.last.availability_manager.per_week).to eq 1
	    expect(User.last.availability_manager.occurrence_rules.to_s).to eq "[Weekly on Mondays on the 2nd hour of the day on the 0th minute of the hour on the 0th second of the minute]"
  	end

  	it "should have a user time zone present", :js => true do
  		visit new_user_path
			click_link "I am a tutor"
	    fill_in_user_info
	    click_link('Add a time available')
	    click_button('Create User')
  		expect(User.last.time_zone).to eq "America/New_York"
  	end
	end

	describe 'switching between tutors and tutees' do 
		it 'should have different time zones for tutors and tutees', :js => true do
			visit new_user_path
			click_link "I am a tutor"
			fill_in_user_info
			click_link "Add a time available"
			within(".fields") do
				expect(page).to have_content "10 pm"
			end
		end

		it 'should have different time zones for tutors and tutees', :js => true do
			visit new_user_path
			click_link "I am a tutee"
			fill_in_user_info
			click_link "Add a time available"
			within(".fields") do
				expect(page).to have_content "7:30 am"
			end
		end

		it "should have a new york time zone for a tutor", js: true do
			visit new_user_path
			click_link "I am a tutor"
			fill_in_user_info
			click_link "Add a time available"
			click_button "Create User"
			expect(User.last.time_zone).to eq "America/New_York"
		end

		it "should have a new delhi time zone for a tutor", js: true do
			visit new_user_path
			click_link "I am a tutee"
			fill_in_user_info
			click_link "Add a time available"
			click_button "Create User"
			expect(User.last.time_zone).to eq "New Delhi"
		end

		it "should have matching times for users", :js => true do
			User.delete_all
			Timecop.travel(Time.current.beginning_of_week)
			visit new_user_path
			click_link "I am a tutor"
			fill_in_user_info
			click_link "Add a time available"
			click_button "Create User"

			visit new_user_path
			click_link "I am a tutee"
			fill_in_user_info
			click_link "Add a time available"
			select "Monday", :from => 'day open'
			select "7:30 am", :from => 'time open'
			click_button "Create User"
			expect(page).to have_content "09:00PM"
		end
	end

	def fill_in_user_info
		fill_in('Name', :with => 'Bob')
    fill_in('Email', :with => 'bob@gmail.com')
    fill_in('Cell number', :with => '+12154997415')
    fill_in('Password', :with => 'hello')
    fill_in('Password confirmation', :with => 'hello')
	end
end