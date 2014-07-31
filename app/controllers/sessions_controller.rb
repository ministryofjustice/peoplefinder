class SessionsController < ApplicationController
  skip_before_filter :ensure_user

  def create
    user = User.from_auth_hash(auth_hash)
    if user
      session['current_user_id'] = user.id
      redirect_to home_path
    else
      warning :login_failed
      redirect_to login_path
    end
  end

  def new
    if params[:failed]
      warning :login_failed
    end
  end

  def destroy
    session['current_user_id'] = nil
    redirect_to home_path
  end

protected
  def auth_hash
    request.env['omniauth.auth']
  end
end
