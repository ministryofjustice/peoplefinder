class ApplicationController < ActionController::Base
  include FeatureHelper

  helper MojHelper

  protect_from_forgery with: :exception
  before_action :ensure_user

private

  def user_for_paper_trail
    logged_in? ? current_user.id : nil
  end

  def info_for_paper_trail
    { ip_address: request.remote_ip, user_agent: request.user_agent }
  end

  def can_add_person_here?
    false
  end
  helper_method :can_add_person_here?

  def load_user
    Login.current_user(session) || ReadonlyUser.from_request(request)
  end

  def current_user
    @current_user ||= load_user
  rescue ActiveRecord::RecordNotFound
    session.destroy
  end
  helper_method :current_user

  def logged_in?
    current_user.present?
  end
  helper_method :logged_in?

  def logged_in_regular?
    logged_in? && current_user.is_a?(Person)
  end
  helper_method :logged_in_regular?

  def super_admin?
    logged_in? && current_user.super_admin?
  end
  helper_method :super_admin?

  def ensure_user
    return true if logged_in?
    session[:desired_path] = request.fullpath
    redirect_to new_sessions_path
  end

  def login_person(person)
    login_service = Login.new(session, person)
    login_service.login

    path = session.delete(:desired_path) || '/'
    if path == '/' && login_service.edit_profile?
      path = edit_person_path(person, prompt: :profile)
    end
    redirect_to path
  end

  def i18n_flash(type, *partial_key, **options)
    full_key = [
      :controllers, controller_path, *partial_key
    ].join('.')
    flash[type] = I18n.t(full_key, options)
  end

  def notice(*partial_key, **options)
    i18n_flash :notice, partial_key, options
  end

  def error(*partial_key, **options)
    i18n_flash :error, partial_key, options
  end
end
