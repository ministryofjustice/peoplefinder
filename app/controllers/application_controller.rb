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

  def current_person
    if logged_in?
      Person.where(email: current_user.email).first
    end
  end
  helper_method :current_person

  def logged_in?
    current_user.present?
  end
  helper_method :logged_in?

  def ensure_user
    return true if logged_in?
    session[:desired_path] = request.fullpath
    redirect_to new_sessions_path
  end

  def redirect_to_desired_path
    path = session.fetch(:desired_path, '/')
    session.delete :desired_path
    redirect_to path
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

  def notice(partial_key, options = {})
    i18n_flash :notice, partial_key, options
  end

  def error(partial_key, options = {})
    i18n_flash :error, partial_key, options
  end
end
