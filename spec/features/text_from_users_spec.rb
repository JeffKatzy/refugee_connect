require 'spec_helper'

describe 'TextFromUsers' do
	describe 'texted go when appointment in next hour' do
		it 'should start a call between the two users' do
			page.driver.browser.process(:post, text_from_user_path, { params: {
      cell_number: "+12154997415",
      body: "name@example.com" } 
      } )
		end
	end

	describe 'texted go when appointment not in next hour' do
		it 'should send the user an error message' do
			page.driver.post('/text_from_user', { :params => { :cell_number => "+12154997415", :body => "go" } })
		end
	end

	describe 'texted sorry when appointment upcoming' do
		page.driver.post('/text_from_user', { :params => { :cell_number => "+12154997415", :body => "sorry" } })
	end

	describe 'texted page number when appointment complete' do
		page.driver.post('/text_from_user', { :params => { :cell_number => "+12154997415", :body => "25" } })
	end
end