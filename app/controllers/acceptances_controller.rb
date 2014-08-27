class AcceptancesController < ApplicationController
  def edit
  end

  def update
    @acceptance = Review.find(params[:id])
    @acceptance.update_attributes(review_params)
    redirect_to submissions_path
  end

private

  def review_params
    params.require(:review).
      permit(:status)
  end
end
