class AcceptancesController < ApplicationController
  before_action :set_acceptance, only: [:edit, :update]

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

  def set_acceptance
    @acceptance = current_user.submissions.where(id: params[:id]).first
  end
end
