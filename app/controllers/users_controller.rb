class UsersController < ApplicationController
  layout 'application'
  
  def new
    @user = User.new
  end

  def create
    @user = User.create(params[:user])
    session[:user_id] = @user.id
    authentication
    redirect_to match_users_path(@user)
  end

  def new_tutor
    @user = User.new
  end

  def new_tutee
    @user = User.new
  end

  def index
    @users = User.all
  end

  def match
    if @auth.present?
      @user = User.find(params[:user_id]) 
      @matches = @user.matches.available.after(Time.current).before(Time.current + 7.days).present?
    else 
      redirect_to root_path
    end
  end

  def show
    @user = User.find(params[:id])
  end
end