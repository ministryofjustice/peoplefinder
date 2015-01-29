module Peoplefinder
  class ApplicationController < ActionController::Base
    include FeatureHelper

    helper MojHelper
    force_ssl if Rails.configuration.try(:start_secure_session)

    protect_from_forgery with: :exception
    before_action :ensure_user

  private

    def user_for_paper_trail
      logged_in? ? current_user.to_s : Peoplefinder::Version.public_user
    end

    def current_user
      @current_user ||= Peoplefinder::Login.current_user(session)
    rescue ActiveRecord::RecordNotFound
      session.destroy
    end
    helper_method :current_user

    def logged_in?
      current_user.present?
    end
    helper_method :logged_in?

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
      login_service = Peoplefinder::Login.new(session, person)
      login_service.login

      path = session.delete(:desired_path) || '/'
      if path == '/' && login_service.edit_profile?
        path = edit_person_path(person, prompt: :profile)
      end
      redirect_to path
    end

    def set_hint_group
      if session[:last_group_visited]
        @hint_group = Group.find(session[:last_group_visited])
      end
    end

    def i18n_flash(type, *partial_key, **options)
      full_key = [
        :peoplefinder, :controllers, controller_name, *partial_key
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
end
