require 'secure'
class TokensController < ApplicationController
  skip_before_action :ensure_user
  before_action :ensure_token_auth_enabled!

  def create
    token_sender = TokenSender.new(token_params[:user_email])
    token_sender.call(self)
  end

  def show
    session[:desired_path] = params[:desired_path] if params[:desired_path]
    token_value = params[:id]
    token_login = TokenLogin.new(token_value)
    token_login.call(self)
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

  def login_and_render person
    login_person(person)
  end

  def render_new_sessions_path_with_invalid_token
    error :invalid_token
    redirect_to new_sessions_path
  end

  def render_new_sessions_path_with_expired_token
    error :expired_token, time: Token.ttl_in_hours
    redirect_to new_sessions_path
  end

  private

  def ensure_token_auth_enabled!
    return if feature_enabled?('token_auth')
    flash[:notice] = t('.token_auth_disabled')
    redirect_to(new_sessions_path)
  end

  def token_params
    params.require(:token).permit([:user_email])
  end

  def unauthorised_login
    params[:token][:unauthorised_login]
  end

end
