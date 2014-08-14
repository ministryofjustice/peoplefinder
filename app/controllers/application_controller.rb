class ApplicationController < ActionController::Base
  force_ssl if Rails.configuration.start_secure_session

  protect_from_forgery with: :exception
  before_action :ensure_user

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

  def warning(partial_key, options = {})
    i18n_flash :warning, partial_key, options
  end

  def access_denied
    render text: 'You do not have permission to edit this record', status: 403
  end
end
