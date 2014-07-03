class OpeningsController < ApplicationController
	respond_to :html, :json
	def update
		@opening = Opening.find(params[:id])
		@opening.update_attributes(params[:opening])
		@opening.set_time
		@opening.build_specific_opening
		respond_with @opening
	end

	def create
		@opening = Opening.new(params[:opening])
		if @opening.save 
			redirect_to user_path(@opening.user)
		end
	end
end