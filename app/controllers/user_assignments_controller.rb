class UserAssignmentsController < ApplicationController
	respond_to :html, :json
	def assign
		assignment_id = params[:id].to_i
		User.last(10).each do |user|
			ua = user.user_assignments.build(assignment_id: assignment_id)
			ua.save
		end
		redirect_to lessons_path
	end

	end

	def update
		@user_assignment = UserAssignment.find(params[:id])
	    @user_assignment.update_attributes(params[:user_assignment])
	    respond_with @user_assignment
	end
end