class TextToUsersController < ApplicationController
	def complete
		@text = TextToUsers.find(params[:id])
		@text.received = params[:MessageSid]
		@text.save
	end
end