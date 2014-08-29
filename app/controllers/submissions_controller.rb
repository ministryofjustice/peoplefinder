class SubmissionsController < ApplicationController
  before_action :set_submission, only: [:edit, :update]

  def index
    @submissions = scope.submissions.all
    @feedback_requests = scope.feedback_requests.all
  end

  def edit
  end

  def update
    @submission.update_attributes(submission_params)
    redirect_to submissions_path
  end

private

  def submission_params
    params.require(:submission).
      permit(:rating, :achievements, :improvements, :submitted)
  end

  def set_submission
    @submission = scope.submissions.where(id: params[:id]).first
  end

  def scope
    current_user
  end
end
