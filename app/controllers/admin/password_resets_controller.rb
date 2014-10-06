module Admin
  class PasswordResetsController < AdminController
    skip_before_action :ensure_administrator

    def new
    end

    def create
      redirect_to new_login_path, notice: 'Password reset link sent'
    end
  end
end
