class PagesController < ApplicationController
layout 'pages'
  def home
  	@user = User.new
  end
end