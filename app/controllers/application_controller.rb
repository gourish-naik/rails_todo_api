class ApplicationController < ActionController::API
  
  private
  
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    
    unless token
      render json: { 
        data:{
          error: { 
            msg: "Access token required" 
          } 
        }
      }, status: :unauthorized
      return
    end
    
    @current_user_login = UserLogin.where(token: token)
                                   .where('token_exp_time > ?', Time.current)
                                   .first
    
    unless @current_user_login
      render json: { 
        data:{
          error: { 
            msg: "Invalid or expired token" 
          } 
        }
      }, status: :unauthorized
      return
    end
    
    @current_user = AppUser.find(@current_user_login.user_id)
  end
  
  def current_user
    @current_user
  end
  
  def current_user_login
    @current_user_login
  end
end