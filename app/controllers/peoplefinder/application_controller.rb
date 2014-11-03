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
      @current_user ||=
        if session['current_user_id'].present?
          Person.find(session['current_user_id'])
        else
          false
        end
      rescue ActiveRecord::RecordNotFound
        session.destroy
    end
    helper_method :current_user

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

      if path == '/' && current_user.incomplete?
        path = edit_person_path(current_user, prompt: :profile)
      end

      redirect_to path
    end

    def set_hint_group
      if session[:last_group_visited]
        @hint_group = Group.find(session[:last_group_visited])
      end
    end

    def i18n_flash(type, partial_key, options = {})
      full_key = [
        :peoplefinder, :controllers, controller_name, partial_key
      ].join('.')
      flash[type] = I18n.t(full_key, options)
    end

    def notice(partial_key, options = {})
      i18n_flash :notice, partial_key, options
    end

    def error(partial_key, options = {})
      i18n_flash :error, partial_key, options
    end
  end
end
