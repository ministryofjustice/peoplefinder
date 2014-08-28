class SubmissionsController < ApplicationController
  before_action :set_submission, only: [:edit, :update]

  def index
    @submissions = current_user.submissions.all
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
      permit(:rating, :achievements, :improvements)
  end

  def set_submission
    @submission = current_user.submissions.where(id: params[:id]).first
  end
end
