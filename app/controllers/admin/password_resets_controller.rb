module Admin
  class PasswordResetsController < AdminController
    skip_before_action :ensure_administrator

    def new
    end

    def create
      @password_reset = PasswordReset.new(email: params[:email])
      if @password_reset.save
        AdminUserMailer.password_reset(@password_reset).deliver
        redirect_to new_login_path, notice: 'Password reset link sent'
      else
        render :new
      end
    end

    def edit
      @token = params[:token]
    end

    def update
      @identity = Identity.find_by_password_reset_token(params[:token])
      if @identity && @identity.can_reset_password?
        @identity.update_attributes(password_params)
      end
      redirect_to new_login_path
    end

  private

    def password_params
      params.permit(:password, :password_confirmation)
    end
  end
end
