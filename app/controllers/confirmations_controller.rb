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
			@specific_opening = @confirmation.specific_opening
			@specific_opening.update_attributes(status: 'confirmed')
      redirect_to specific_opening_confirmation_path(@specific_opening, @confirmation)
    else
      render action: 'new'
    end
	end

	def show
		@specific_opening = SpecificOpening.find(params[:specific_opening_id])
		@appointment = @specific_opening.appointment
	end

	def index
		@specific_opening = SpecificOpening.find(params[:specific_opening_id])
		@confirmation = @specific_opening.confirmations.last
		@appointment = @specific_opening.appointment
		@user = @specific_opening.user
	end

	def helper_url(appointment)
		@helper_url = Rails.application.routes.url_helpers.appointment_path(appointment)
	end
end