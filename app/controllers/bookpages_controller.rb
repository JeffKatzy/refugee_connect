class BookpagesController < ApplicationController
	def new 
    	@bookpage = Bookpage.new
	end

	def create

		@bookpage = Bookpage.new(params[:bookpage])
    if @bookpage.save
      redirect_to bookpages_path
    else
      render action: 'new'
    end
	end

	def index
		@bookpages = Bookpage.all
	end
end