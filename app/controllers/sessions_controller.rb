class SessionsController < ApplicationController
  skip_before_action :ensure_user

  before_action :set_login_screen_flag

  def create
    person = FindCreatePerson.from_auth_hash(auth_hash)

    if person
      login_person(person)
    else
      render :failed
    end
  end

  def new
    @unauthorised_login = session.delete(:unauthorised_login)
  end

  def destroy
    Login.new(session, @current_user).logout

    redirect_to '/'
  end

  private

  def set_login_screen_flag
    @login_screen = true
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
