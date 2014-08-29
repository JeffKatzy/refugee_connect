class ProfileInfosController < ApplicationController
	respond_to :html, :json

	def update
		profile_info = ProfileInfo.find(params[:id])
    profile_info.update_attributes(params[:profile_info])
    respond_with @profile_info
	end
end