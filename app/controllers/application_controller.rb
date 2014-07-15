class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  before_filter :ensure_user

private
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
end
