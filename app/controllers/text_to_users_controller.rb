class TextToUsersController < ApplicationController

	def complete
		@text = TextToUser.find(params[:id])
		@text.received = params[:MessageStatus]
		@text.save
		render nothing: true
	end
end