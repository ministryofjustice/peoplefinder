class TokensController < ApplicationController
  skip_before_action :ensure_user

  def show
    token = Token.where(value: params[:id]).first
    if token
      session[:current_user_id] = token.user_id
      redirect_to dashboard_path
    else
      render 'shared/forbidden', status: 500
    end
  end
end
