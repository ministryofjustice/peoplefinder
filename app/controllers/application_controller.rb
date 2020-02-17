class ApplicationController < ActionController::Base
  include Pundit
  include FeatureHelper

  protect_from_forgery with: :exception

  before_action :check_maintenance_mode
  before_action :ensure_user

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def login_person(person)
    login_service = Login.new(session, person)
    login_service.login
    redirect_to desired_path(person)
  end

  # rubocop:disable AndOr
  def maintenance_mode
    redirect_to '/' and return unless maintenance_mode_on?
    render layout: nil, file: 'layouts/maintenance'
  end

  private

  def maintenance_mode_on?
    File.exist? Rails.root.join('maintenance.txt')
  end

  def check_maintenance_mode
    if maintenance_mode_on? && request.fullpath != '/maintenance'
      redirect_to '/maintenance' and return
    end
  end

  def user_for_paper_trail
    logged_in_regular? ? current_user.id : nil
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

  def logged_in_readonly?
    logged_in? && current_user.is_a?(ReadonlyUser)
  end
  helper_method :logged_in_readonly?

  def super_admin?
    logged_in? && current_user.super_admin?
  end
  helper_method :super_admin?

  def ensure_user
    return true if logged_in?
    session[:desired_path] = request.fullpath
    redirect_to new_sessions_path
  end

  def desired_path person
    session.delete(:desired_path) || person_path(person, prompt: :profile)
  end

  def i18n_flash(type, *partial_key, **options)
    full_key = [
      :controllers, controller_path.tr('/', '.'), *partial_key
    ].join('.')
    flash[type] = I18n.t(full_key, options)
  end

  def warning(*partial_key, **options)
    i18n_flash :warning, partial_key, options
  end

  def notice(*partial_key, **options)
    i18n_flash :notice, partial_key, options
  end

  def error(*partial_key, **options)
    i18n_flash :error, partial_key, options
  end

  def user_not_authorized
    if logged_in_readonly?
      session[:desired_path] = request.fullpath
      session[:unauthorised_login] = true
      redirect_to new_sessions_path
    elsif logged_in_regular?
      warning :unauthorised
      redirect_to home_path
    end
  end
end
