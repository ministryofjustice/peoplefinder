class ApplicationController < ActionController::Base
  force_ssl if Rails.env.production?

  protect_from_forgery with: :exception
  before_filter :ensure_user

private
  def user_for_paper_trail
    logged_in? ? current_user.to_s : 'Public user'
  end

  def current_user
    session['current_user']
  end
  helper_method :current_user

  def logged_in?
    current_user.present?
  end
  helper_method :logged_in?

  def ensure_user
    redirect_to new_sessions_path unless logged_in?
  end

  def set_hint_group
    if session[:last_group_visited]
      @hint_group = Group.find(session[:last_group_visited])
    end
  end
end
