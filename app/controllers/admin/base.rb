module Admin
  class Base < ApplicationController
    skip_before_action :ensure_user
    before_action :ensure_administrator

  private

    def ensure_administrator
      return true if administrator?
      session[:goal] = request.original_fullpath
      redirect_to new_login_path
      false
    end
  end
end
