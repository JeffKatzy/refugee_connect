class LessonsController < ApplicationController
	def new 
    @lesson = Lesson.new
    @lesson.assignments.build
	end

	def create
		@lesson = Lesson.new(params[:lesson])
	    if @lesson.save
	      redirect_to lessons_path
	    else
	      render action: 'new'
	    end
	end

	def index
		@lessons = Lesson.all
	end
end