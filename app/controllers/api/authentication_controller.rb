class Api::AuthenticationController < ApplicationController
  def login
    username = params[:username]
    password = params[:password]

    #check if username exists
    user = AppUser.find_by(username: username)
    unless user
      render json:{
        data:{
          error: {
            msg:"User name not found"
          }
        }
      }, status: :not_found
      return
    end

    #check password
    unless user.password == password
      render json:{
        data:{
          error:{
            msg:"invalid password"
          }
        }
      }, status: :unauthorized
      return
    end

    tokens = user.create_login_session

    render json:{
      data:{
        token: tokens[:access_token],
        refresh_token: tokens[:refresh_token],
        msg:"Login successful"
      }
    },status: :ok
    return
  end


  # Refresh token

  def refresh
    refresh_token = params[:refresh_token]

    unless refresh_token
      render json:{
        data:{
          error:{
            msg:"Refresh token required"
          }
        }
      },status: :bad_request
      return
    end

    #fine active refresh token
    user_login = UserLogin.joins(:user)
                          .where(refresh_token: refresh_token)
                          .where('ref_token_exp_time > ?', Time.current)
                          .first
    unless user_login
      render json:{
        data:{
          error:{
            msg: "Invalid or expired refresh token" 
          }
        }
      }, status: :unauthorized
      return
    end

    user = user_login.user
    new_token = user.generate_tokens

    # update the login session
    user_login.update!(
      token: new_token[:access_token],
      refresh_token: new_token[:refresh_token],
      token_exp_time: new_token[:token_exp_time],
      ref_token_exp_time: new_token[:ref_token_exp_time]
    )

    render json:{
      data:{
        msg: "Token refreshed successfully",
        token: new_tokens[:access_token],
        refresh_token: new_tokens[:refresh_token]
      }
    }, status: :ok
  end

  def logout
    username = params[:username]
    token = params[:token]
  
    unless username && token
      render json: {
        data:{
          error: {
          msg: "Username and token required" 
        }
        }
      }, status: :bad_request
      return
    end
  
    # Find user_login by username and token directly
    user_login = UserLogin.where(username: username, token: token).first
  
    unless user_login
      render json: {
        data:{
          error: {
            msg: "Invalid details!"
          }
        }
      }, status: :not_found
      return
    end
  
    # Clear token 
    user_login.update!(
      token: nil,
      token_exp_time: Time.current - 1.hour
    )
  
    render json: {
      data: {
        msg: "Logout successful"
      }
    }, status: :ok
  end

end
