require 'secure'
class TokensController < ApplicationController
  include SessionPersonCreator

  skip_before_action :ensure_user
  before_action :ensure_token_auth_enabled!

  def create
    token_sender = TokenSender.new(token_params[:user_email])
    token_sender.call(self)
  end

  def show
    session[:desired_path] = params[:desired_path] if params[:desired_path]
    if logged_in_regular?
      render_desired_path_or_profile
    else
      token_value = params[:id]
      token_login = TokenLogin.new(token_value)
      token_login.call(self)
    end
  end

  def render_new_view_with_errors token:
    @unauthorised_login = unauthorised_login
    @token = token
    render action: :new
  end

  def render_create_view token:
    @unauthorised_login = unauthorised_login
    @token = token
    render action: :create
  end

  def render_new_sessions_path_with_expired_token_message
    error :expired_token
    redirect_to new_sessions_path
  end

  private

  def render_desired_path_or_profile
    path = session.delete(:desired_path) || person_path(current_user)
    redirect_to path
  end

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
