module Peoplefinder
  class TokensController < ApplicationController
    skip_before_action :ensure_user
    before_action :set_desired_path, only: [:show]
    before_action :ensure_token_auth_enabled!

    def create
      @token = Token.new(token_params)
      if @token.save
        TokenMailer.new_token_email(@token).deliver_later
        render
      else
        render action: :new
      end
    end

    def show
      token = Token.where(value: params[:id]).first
      if token && token.active?
        person = FindCreatePerson.from_token(token)
        login_person(person)
      elsif token.nil?
        error :invalid_token
        redirect_to new_sessions_path
      elsif !token.active?
        error :expired_token, hours: Token.ttl
        redirect_to new_sessions_path
      end
    end

  protected

    def ensure_token_auth_enabled!
      return if feature_enabled?('token_auth')
      flash[:notice] = t('.token_auth_disabled')
      redirect_to(new_sessions_path)
    end

    def token_params
      params.require(:token).permit([:user_email])
    end

    def set_desired_path
      if params[:desired_path]
        session[:desired_path] = params[:desired_path]
      end
    end
  end
end
