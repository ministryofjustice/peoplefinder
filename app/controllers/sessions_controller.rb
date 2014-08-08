class SessionsController < ApplicationController
  skip_before_action :ensure_user

  def create
    user = User.from_auth_hash(auth_hash)
    session['current_user'] = user
    if user
      redirect_to '/'
    else
      render :failed
    end
  end

  def new
  end

  def destroy
    session['current_user'] = nil
    redirect_to '/'
  end

protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
