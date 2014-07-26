class ConfirmationsController < ApplicationController
	def new
		@specific_opening = SpecificOpening.find(params[:specific_opening_id])
		@user = @specific_opening.user
		@confirmation = Confirmation.new
	end

	def create
		@confirmation = Confirmation.new(params[:confirmation])
		if @confirmation.save
			@user = @confirmation.user
      redirect_to user_confirmation_path(@user, @confirmation)
    else
      render action: 'new'
    end
	end

	def show
	end
end