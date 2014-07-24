class PasswordsController < ApplicationController
  skip_before_filter :ensure_user

  before_filter :load_user_by_token, only: [:show, :update]

  def new; end

  def create
    user = User.where(email: params[:email]).first
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
    if @user.update_attributes(auth_params)
      notice :updated
      redirect_to new_sessions_path
    else
      error :update_failed
      @token = user.token
      render :show
    end
  end

  def show; end

private
  def load_user_by_token
    @user = User.from_token(params[:token])
    if @user
      @token = @user.token
    else
      warning :invalid_token
      redirect_to new_passwords_path
    end
  end

  def auth_params
    params.permit(:password, :password_confirmation)
  end
end
