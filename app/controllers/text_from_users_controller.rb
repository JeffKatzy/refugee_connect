class TextFromUsersController < ApplicationController
	def create
		@text_from_user = TextFromUser.create(:incoming_number => params['From'], :body => params['Body'].downcase)
	end
end