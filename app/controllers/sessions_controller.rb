class SessionsController < ApplicationController
	layout 'pages'
	
	def new
		@user = User.new
	end

	def create
		@user = User.where(:email => params[:session][:email]).first
		if @user.present? && @user.authenticate(params[:session][:password])
			session[:user_id] = @user.id
			redirect_to @user
			flash[:success] = "Welcome to the Sample App!"
		else
			flash.now[:error] = 'Invalid email/password combination'
			render 'new'
		end
	end

	def callback
		
	end

	def destroy
		session[:user_id] = nil
		redirect_to root_path
	end

	def create_omniauth
    user = User.from_omniauth(env['omniauth.auth'])
    session[:user_id] = user.id
    redirect_to users_path
  end
end
