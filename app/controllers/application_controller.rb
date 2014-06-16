class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  before_filter :ensure_user

  private

  def ensure_user
    if session['current_user'].blank?
      redirect_to new_sessions_path
    end
  end
end
