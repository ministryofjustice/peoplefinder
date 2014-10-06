module Admin
  class PasswordResetsController < AdminController
    skip_before_action :ensure_administrator

    def new
    end
  end
end
