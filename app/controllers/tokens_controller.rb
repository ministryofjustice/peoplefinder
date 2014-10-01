class TokensController < ApplicationController
  skip_before_action :ensure_user, :check_review_period_is_open

  def show
    token = Token.where(value: params[:id]).first

    if token.nil? || token.expired?
      return forbidden
    end

    authenticate_with(token)
  end

private

  def authenticate_with(token)
    if token.user
      session[:user_id] = token.user_id
      redirect_to reviews_path

    elsif token.review
      user = User.find_or_create_by(email: token.review.author_email)
      session[:user_id] = user.id
      redirect_to replies_path
    end
  end
end
