class TextFromUsersController < ApplicationController
	def create
		@text_from_user = TextFromUser.new(:incoming_number => params['From'], :body => params['Body'].downcase)
		@text_from_user.user = User.find_by_cell_number(@text_from_user.incoming_number)
		@text_from_user.save
	end
end