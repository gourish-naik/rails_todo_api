class Api::UsersController < ApplicationController
  def new
    @user = AppUser.new 
  end
  
  def create
    @user = AppUser.new(user_params)
    
    if @user.save

      tokens = @user.create_login_session

      render json: { 
        data: {
          token: tokens[:access_token],
          refresh_token: tokens[:refresh_token],
          msg: "User created successfully",
          redirect_url: '/login', # replace with your actual path
          user: @user
        }
      }, status: :created
    else
      render json: { 
        data: {
          error:{
            msg: "User has already been taken!",
            error: @user.errors
          }
        }
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  def user_params
    params.permit(:username, :password)  # Remove the fetch/require
  end
end