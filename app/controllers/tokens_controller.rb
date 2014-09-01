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
      redirect_to reviews_path

    elsif token.review
      user = User.find_or_create_by(email: token.review.author_email)
      session[:current_user_id] = user.id
      redirect_to replies_path
    end
  end
end
