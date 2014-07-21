class PasswordsController < ApplicationController
  skip_before_filter :ensure_user

  before_filter :load_user_by_token, only: [:show, :update]

  def new; end

  def create
    user = User.where(email: password_params[:email]).first
    if user
      user.start_password_reset_flow!
      redirect_to new_passwords_path, notice: 'An email with a link to reset your password has been sent'
    else
      flash[:error] = "An account with that email address can't be found"
      render :new
    end
  end

  def update
    if @user
      @user.update_password!(auth_params[:password], auth_params[:password_confirmation])
      redirect_to new_sessions_path, notice: 'Your password has been updated'
    else
      flash[:error] = 'There was a problem updating your password details'
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
      flash[:error] = "That doesn't appear to be a valid token"
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