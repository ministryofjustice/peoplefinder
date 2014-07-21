class PasswordsController < ApplicationController
  skip_before_filter :ensure_user

  before_filter :load_user_by_token, only: [:show, :update]

  def new; end

  def create
    user = User.where(email: password_params[:email]).first
    if user
      user.start_password_reset_flow!
      notice :reset_sent
      redirect_to new_passwords_path
    else
      warning :email_not_found
      render :new
    end
  end

  def update
    if @user
      @user.update_password!(auth_params[:password], auth_params[:password_confirmation])
      notice :updated
      redirect_to new_sessions_path
    else
      error :update_failed
      @token = user.password_reset_token
      render :show
    end
  end

  def show; end

private
  def load_user_by_token
    @user = User.where(password_reset_token: token_params[:token]).first
    if @user
      @token = @user.password_reset_token
    else
      warning :invalid_token
      redirect_to new_passwords_path
    end
  end

  def password_params
    params.permit(:email)
  end

  def token_params
    params.permit(:token)
  end

  def auth_params
    params.permit(:token, :password, :password_confirmation)
  end
end
