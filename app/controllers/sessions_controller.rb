class SessionsController < ApplicationController
  skip_before_action :ensure_user

  def create
    person = FindCreatePerson.from_auth_hash(auth_hash)

    if person
      login_person(person)
    else
      render :failed
    end
  end

  def new
  end

  def destroy
    Login.new(session, @current_user).logout

    redirect_to '/'
  end

protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
