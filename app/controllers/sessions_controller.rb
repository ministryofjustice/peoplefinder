class SessionsController < ApplicationController
  include SessionPersonCreator
  include UserAgentHelper

  skip_before_action :ensure_user

  before_action :set_login_screen_flag

  def new
    @unauthorised_login = session.delete(:unauthorised_login)
    redirect_to unsupported_browser_new_sessions_path if unsupported_browser?
  end

  def destroy
    Login.new(session, @current_user).logout
    redirect_to "/"
  end

  def create_person
    @person = Person.new(person_params)
    @person.skip_must_have_team = true
    create_person_and_login @person
  end

private

  def person_params
    params.require(:person)
      .permit(
        :given_name,
        :surname,
        :email,
      )
  end

  def set_login_screen_flag
    @login_screen = true
  end
end
