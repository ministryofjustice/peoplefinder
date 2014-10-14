module Peoplefinder
  class SessionsController < ApplicationController
    skip_before_action :ensure_user

    def create
      person = Person.from_auth_hash(auth_hash)
      if person
        session['current_user_id'] = person.id
        redirect_to_desired_path
      else
        render :failed
      end
    end

    def new
    end

    def destroy
      session['current_user_id'] = nil
      redirect_to '/'
    end

  protected

    def auth_hash
      request.env['omniauth.auth']
    end
  end
end
