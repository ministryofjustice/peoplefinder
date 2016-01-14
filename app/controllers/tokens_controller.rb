require 'secure'
class TokensController < ApplicationController
  skip_before_action :ensure_user
  before_action :set_desired_path, only: [:show]
  before_action :ensure_token_auth_enabled!

  def create
    token_sender = TokenSender.new(token_params[:user_email])
    token_sender.call(self)
  end

  def render_new_view user_email_error:
    @unauthorised_login = unauthorised_login
    @user_email_error = user_email_error
    render action: :new
  end

  def render_create_view token:
    @unauthorised_login = unauthorised_login
    @token = token
    render action: :create
  end

  def show
    token = find_token_securly(params[:id])
    if token
      verify_active_token(token)
    else
      error :invalid_token
      redirect_to new_sessions_path
    end
  end

  protected

  def verify_active_token(token)
    if token.active?
      person = FindCreatePerson.from_token(token)
      login_person(person)
      token.destroy!
    else
      error :expired_token, time: ttl_seconds_in_hours
      redirect_to new_sessions_path
    end
  end

  def ensure_token_auth_enabled!
    return if feature_enabled?('token_auth')
    flash[:notice] = t('.token_auth_disabled')
    redirect_to(new_sessions_path)
  end

  def token_params
    params.require(:token).permit([:user_email])
  end

  def set_desired_path
    if params[:desired_path]
      session[:desired_path] = params[:desired_path]
    end
  end

  private

  def unauthorised_login
    params[:token][:unauthorised_login]
  end

  def find_token_securly(token)
    Token.find_each do |t|
      return t if Secure.compare(t.value, token)
    end
  end

  def ttl_seconds_in_hours
    minutes = Token.ttl.div(60)
    hours = minutes.div(60)
    hours
  end
end
