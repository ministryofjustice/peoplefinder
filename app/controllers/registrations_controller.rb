class RegistrationsController < ApplicationController
  skip_before_filter :ensure_user
  before_filter :load_user_by_token, only: [:new, :update]

  def new; end

  def update
    @user.attributes = user_params
    if @user.save
      notice :registration_success
      redirect_to new_sessions_path
    else
      error :failed_registration
      render :new
    end
  end
  
  private

  def load_user_by_token
    @user = User.from_token(token)
    if @user.nil?
      notice :invalid_token
      # redirect_to new_sessions_path
    end
  end

  def token
    params[:user] && params[:user][:token] ? params[:user][:token] : params[:token]
  end

  def token_params
    params.permit(:token)
  end

  def user_params
    params[:user].permit(:password, :password_confirmation, :token)
  end

end