class AdminController < ApplicationController
  skip_before_action :ensure_user
  skip_before_action :check_review_period_is_open
  before_action :ensure_administrator

private

  def ensure_administrator
    return true if administrator?
    session[:goal] = request.original_fullpath
    redirect_to new_login_path
    false
  end
end
