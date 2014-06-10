class TextFromUsersController < ApplicationController
	def create
		@text_from_user = TextFromUser.new(:incoming_number => params['From'],
			 :body => params['Body'].downcase, 
			 city: params['FromCity'], 
			 state: params['FromState'], 
			 zip: params['FromZip'],
			 country: params['FromCountry']
			 )
		@text_from_user.format_phone_number
		@text_from_user.save
	end
end