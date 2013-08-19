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
	    page.should have_button('Create User')
	  end
	end

	describe 'POST /user' do
  	it 'creates a new user', :js => true do
	    visit root_path
	    click_link('Register')
	    fill_in('Name', :with => 'Bob')
	    fill_in('Email', :with => 'bob@gmail.com')
	    fill_in('Cell number', :with => '+12154997415')
	    fill_in('Password', :with => 'hello')
	    fill_in('Password confirmation', :with => 'hello')
	    click_link('Add a time available')
	    click_button('Create User')
	    expect(User.last.name).to eq 'Bob'
	    expect(User.last.email).to eq 'bob@gmail.com'
	    expect(User.last.cell_number).to eq '+12154997415'
	    expect(User.last.openings.first.day_open).to eq 'Sunday'
	    expect(User.last.openings.first.time_open).to eq 13
	    expect(User.last.availability_manager.per_week).to eq 1
	    expect(User.last.availability_manager.occurrence_rules.to_s).to eq "[Weekly on Sundays]"
  	end
	end
end