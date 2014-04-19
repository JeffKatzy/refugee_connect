class UsersController < ApplicationController
  layout 'application'

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      authentication
      redirect_to(match_users_path(@user))
    else
      render action: 'new'
    end
  end

  def create_omniauth
    @user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = @user.id
    if @user.new_user == true
      redirect_to new_user_path
    else
      redirect_to user_path(@user.id)
    end
  end

  def new 
    @user = User.find(session[:user_id]) if session[:user_id]
    @user = User.new unless session[:user_id]
  end

  def new_tutor
    @user = User.find(session[:user_id]) if session[:user_id]
    @user = User.new unless session[:user_id]
    @user.openings.build
  end

  def new_tutee
    @user = User.find(session[:user_id]) if session[:user_id]
    @user = User.new unless session[:user_id]
    @user.openings.build
  end

  def index
    @users = User.all
  end

  def match
    if @auth.present?
      @true_matches = true
      @user = User.find(params[:user_id]) 
      @matches = @user.matches.available.after(Time.current).before(Time.current + 7.days).limit(5)
      if @matches.empty?
        @true_matches = false
        @matches = Match.build_fake_matches_for(@user, User.scoped, Time.current + 7.days).limit(5)
      end
    else 
      redirect_to root_path
    end
  end

  def manual_match
    user = User.find(params[:user_id])
    index = params[:index].to_i
    time = user.availability_manager.remaining_occurrences(Time.current + 14.days)[index]
    match = Match.match_from_users_and_time(user, @auth, time)
    apt = match.convert_to_apt
    redirect_to user
  end

  def show
    @user = User.find(params[:id])
  end
end