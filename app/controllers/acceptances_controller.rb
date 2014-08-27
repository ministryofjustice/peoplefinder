class AcceptancesController < ApplicationController
  skip_before_action :ensure_user, only: [:edit, :update]
  before_action :ensure_review, only: [:edit, :update]

  def edit
  end

  def update
    @acceptance.update_attributes(review_params)
    redirect_to submissions_path
  end

private

  def review_params
    params.require(:review).
      permit(:status)
  end

  def ensure_review
    @acceptance = Review.where(id: session[:review_id]).first
    forbidden unless @acceptance
  end
end
