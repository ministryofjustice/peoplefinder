class ReviewsController < ApplicationController
  def index
    @review = scope.new
    @reviews = scope.all
  end

  def create
    @review = scope.new(review_params)

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

  def scope
    subject.reviews_received
  end

  def subject
    if params[:user_id]
      current_user.managees.find(params[:user_id])
    else
      current_user
    end
  end
end
