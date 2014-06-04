class CommentsController < ApplicationController
	respond_to :html, :json

	def update
		@comment = Comment.find(params[:id])
	  @comment.update_attributes(params[:comment])
	  respond_with @comment
	end
end