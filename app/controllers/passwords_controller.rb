class PasswordsController < ApplicationController
  skip_before_filter :ensure_user

  def new; end

  def create
    user = User.for_email(password_params[:email])
    if user
      user.start_password_reset_flow!
      redirect_to new_passwords_path, notice: 'An email with a link to reset your password has been sent'
    else
      flash[:alert] = "An account with that email address can't be found"
      render :new
    end
  end

  def update
    
  end

  def show

  end
  
  private

  def password_params
    params.permit(:email)
  end

end