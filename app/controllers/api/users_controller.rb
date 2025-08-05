class Api::UsersController < ApplicationController
  def new
    @user = AppUser.new 
  end
  
  def create
    @user = AppUser.new(user_params)
    p @user
    if @user.save
      render json: { 
        message: "User created successfully", 
        redirect_url: '/login', # replace with your actual path
        user: @user 
      }, status: :created
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end
  
  private
  
  def user_params
    params.permit(:username, :password)  # Remove the fetch/require
  end
end