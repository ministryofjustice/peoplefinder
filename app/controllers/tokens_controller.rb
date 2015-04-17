class TokensController < ApplicationController
  skip_before_action :ensure_user
  before_action :set_desired_path, only: [:show]
  before_action :ensure_token_auth_enabled!

  def create
    @token = generate_token(token_params)
    if @token.nil?
      show_throttle_limit_error
    elsif @token.valid?
      send_token_and_render(@token)
    else
      render action: :new
    end
  end

  def show
    token = Token.where(value: params[:id]).first
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

  def send_token_and_render(token)
    TokenMailer.new_token_email(token).deliver_later
    render
  end

  def show_throttle_limit_error
    error :token_throttle_limit, limit: Token.max_tokens_per_hour
    render action: :new
  end

  def ttl_seconds_in_hours
    minutes = Token.ttl.div(60)
    hours = minutes.div(60)
    hours
  end

  def generate_token(token_params)
    @token = Token.create(token_params)
  rescue Token::MaxNumberOfTokensError
    nil
  end
end
