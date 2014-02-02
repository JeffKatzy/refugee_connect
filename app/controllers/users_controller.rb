class UsersController < ApplicationController
  layout 'application'

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      authentication
      redirect_to match_users_path(@user)
    else 
      render 'new'
    end
  end

  def new_tutor
    @user = User.new
    @user.openings.build
  end

  def new_tutee
    @user = User.new
    @user.openings.build
  end

  def index
    @users = User.all
  end

  def match
    if @auth.present?
      @user = User.find(params[:user_id]) 
      @matches = @user.matches.available.after(Time.current).before(Time.current + 7.days)
    else 
      redirect_to root_path
    end
  end

  def show
    @user = User.find(params[:id])
  end
end