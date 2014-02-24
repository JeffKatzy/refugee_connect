class TextToUsersController < ApplicationController
	
	def complete
		@text = TextToUser.find(params[:id])
		@text.received = params[:MessageSid]
		@text.save
	end
end