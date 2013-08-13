class UsersController < ApplicationController
  layout 'application'
  
  def new
    @user = User.new
  end

  def create
    @user = User.create(params[:user])
    redirect_to @user
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end
end