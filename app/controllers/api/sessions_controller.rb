class Api::SessionsController < ApplicationController
	before_action :authenticate_user!, only: [:show]

	
    def create
     @user = User.find_by(username: params[:username])
      if !!@user && @user.authenticate(params[:password])
      	session[:user_id] = @user.id
      	redirect_to user_path
      else
      	message = "something went wrong, Please check your username and password"
         redirect_to login_path, notice: message
      end
    end


end
