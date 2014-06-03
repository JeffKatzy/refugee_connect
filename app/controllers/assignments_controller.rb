class AssignmentsController < ApplicationController
	def new
		@assignment = Assignment.new
		@assignment.bookpages.build
	end

	def create
		@assignment = Assignment.new(params[:assignment])
		if @assignment.valid?
			@assignment.save
			redirect_to assignments_path
		else
			redirect_to new_assignment_path
		end
	end

	def index
	end
end