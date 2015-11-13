require 'secure'
class TokensController < ApplicationController
  skip_before_action :ensure_user
  before_action :set_desired_path, only: [:show]
  before_action :ensure_token_auth_enabled!
  REPORT_EMAIL_ERROR_REGEXP = %r{(not formatted correctly|reached the limit)}

  def create
    @unauthorised_login = params[:token][:unauthorised_login]
    @token = Token.new(token_params)

    if @token.save
      send_token_and_render(@token)
    elsif @token.errors[:user_email].first[REPORT_EMAIL_ERROR_REGEXP]
      render action: :new
    else
      render action: :create
    end
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

  def find_token_securly(token)
    Token.find_each do |t|
      return t if Secure.compare(t.value, token)
    end
  end

  def send_token_and_render(token)
    TokenMailer.new_token_email(token).deliver_later
    render
  end

  def ttl_seconds_in_hours
    minutes = Token.ttl.div(60)
    hours = minutes.div(60)
    hours
  end
end
