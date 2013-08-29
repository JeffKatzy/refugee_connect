class UsersController < ApplicationController
  layout 'application'
  
  def new
    @user = User.new
  end

  def create
    @user = User.create(params[:user])
    session[:user_id] = @user.id
    redirect_to @user
  end

  def index
    @users = User.all
  end

  def match
    if @auth.present?
      @user = @auth
      @matches = @auth.available_appointments_this_week
    else 
      redirect_to root_path
    end
  end

  def show
    @user = User.find(params[:id])
  end
end