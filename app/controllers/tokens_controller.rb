class TokensController < ApplicationController
  skip_before_action :ensure_user

  def show
    token = Token.where(value: params[:id]).first

    return forbidden unless token

    authenticate_with(token)
  end

private

  def authenticate_with(token)
    if token.user
      session[:current_user_id] = token.user_id
      redirect_to dashboard_path

    elsif token.review
      session[:review_id] = token.review_id
      redirect_to edit_acceptance_path(token.review)
    end
  end
end
