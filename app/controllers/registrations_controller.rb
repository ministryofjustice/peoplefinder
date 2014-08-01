class RegistrationsController < ApplicationController
  skip_before_action :ensure_user
  before_action :load_user_by_token, only: [:new, :update]

  def new
  end

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
      redirect_to new_sessions_path
    end
  end

  def token
    if params[:user] && params[:user][:token]
      params[:user][:token]
    else
      params[:token]
    end
  end

  def user_params
    params[:user].permit(:password, :password_confirmation, :token)
  end
end
