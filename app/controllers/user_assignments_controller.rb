class UserAssignmentsController < ApplicationController
	def assign
		assignment_id = params[:id].to_i
		User.last(10).each do |user|
			ua = user.user_assignments.build(assignment_id: assignment_id)
			ua.save
		end
		redirect_to lessons_path
	end
end