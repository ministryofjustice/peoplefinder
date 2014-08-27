class ReviewsController < ApplicationController
  def index
    @review = Review.new
    @reviews = Review.all
  end

  def create
    @review = Review.new(review_params)
    @review.subject = current_user

    if @review.save
      @review.send_feedback_request
      redirect_to reviews_path
    else
      render action: :index
    end
  end

private

  def review_params
    params.require(:review).
      permit(:author_email, :author_name, :relationship)
  end
end
