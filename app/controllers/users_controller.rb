class UsersController < ApplicationController
  layout 'application'
  respond_to :html, :json

  def create
    @user = User.new(params[:user]) 
    if @user.save
      session[:user_id] = @user.id
      authentication
      redirect_to user_path(@user.id)
      flash_message(:sign_up, "Congrats!  On #{@user.openings.first.day_open} we'll send you a text message asking if you are still free for the class.  Just follow the instructions in the text to confirm or cancel.
        To view the book you will be teaching click the 'View book' link on this page.") 
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

  def update
    u = User.find(params[:id])
    u.update_attributes(params[:user])
    respond_with @user
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
    @tutors = User.where(role: 'tutor')
    @tutees = User.where(role: 'tutee')
  end

  def show
    @user = User.find(params[:id])
    @user.openings.build
    @assignments = Assignment.paginate(:page => params[:page])
    @user_assignments = @assignments.map do |a|
      a = a.user_assignments.where(user_id: @user.id).first || a.user_assignments.create(user_id: @user.id)
    end
    if @auth
      @comments = @user_assignments.map do |ua|
      comment = ua.comments.where(user_assignment_id: ua.id, tutor_id: @auth.id).first || 
        ua.comments.create(user_assignment_id: ua.id, tutor_id: @auth.id)
      end
    end
  end
end