module Admin
  class PasswordResetsController < AdminController
    skip_before_action :ensure_administrator

    def new
      @password_reset = PasswordReset.new
    end

    def create
      email = params[:password_reset][:email]
      @password_reset = PasswordReset.new(email: email)
      if @password_reset.save
        AdminUserMailer.password_reset(@password_reset).deliver
        redirect_to new_login_path, notice: 'Password reset link sent'
      else
        render :new
      end
    end

    def edit
      @identity = Identity.find_by_password_reset_token(params[:token])
      if @identity.nil? || !@identity.can_reset_password?
        redirect_to(
          new_admin_password_reset_path,
          notice: 'Your password reset token has expired'
        )
      end
    end

    def update
      token = params[:identity][:password_reset_token]
      @identity = Identity.find_by_password_reset_token(token)
      if @identity && @identity.can_reset_password?
        if @identity.update_attributes(password_params)
          redirect_to new_login_path
        else
          render :edit
        end
      else
        redirect_to(
          new_admin_password_reset_path,
          notice: 'Your password reset token has expired'
        )
      end
    end

  private

    def password_params
      params.require(:identity).permit(:password, :password_confirmation)
    end
  end
end
