class SessionsController < ApplicationController
  skip_before_filter :ensure_user

  def create
    user = User.from_auth_hash(auth_hash)
    session['current_user'] = user
    if user
      redirect_to '/'
    else
      render :text => "You need to sign in with a MOJ DS or GDS account"
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
