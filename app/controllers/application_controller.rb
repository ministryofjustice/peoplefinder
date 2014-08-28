class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  before_action :ensure_user

private

  def current_user
    @current_user ||= User.where(id: session['current_user_id']).first
  end
  helper_method :current_user

  def logged_in?
    current_user.present?
  end
  helper_method :logged_in?

  def ensure_user
    logged_in? || forbidden
  end

  def forbidden
    render 'shared/forbidden', status: :forbidden
    false
  end

  def i18n_flash(type, partial_key, options = {})
    full_key = ['controllers', controller_name, partial_key].join('.')
    flash[type] = I18n.t(full_key, options)
  end

  def error(partial_key, options = {})
    i18n_flash :error, partial_key, options
  end

  def notice(partial_key, options = {})
    i18n_flash :notice, partial_key, options
  end
end
