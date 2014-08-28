class FeedbackRequestsController < ApplicationController
  before_action :set_feedback_request, only: [:edit, :update]

  def edit
  end

  def update
    @feedback_request.update_attributes(feedback_request_params)
    redirect_to submissions_path
  end

private

  def feedback_request_params
    params.require(:feedback_request).
      permit(:status)
  end

  def set_feedback_request
    @feedback_request = current_user.feedback_requests.
                          where(id: params[:id]).first
  end
end
