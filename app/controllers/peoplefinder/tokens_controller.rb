module Peoplefinder
  class TokensController < ApplicationController
    skip_before_action :ensure_user
    before_action :set_desired_path, only: [:show]

    def create
      @token = Token.new(token_params)
      if @token.save
        TokenMailer.new_token_email(@token).deliver
        render
      else
        render action: :new
      end
    end

    def show
      token = Token.where(value: params[:id]).first
      return forbidden unless token

      person = Person.from_token(token)
      session['current_user_id'] = person.id
      redirect_to_desired_path
    end

  protected

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
