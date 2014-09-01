class SubmissionsController < ApplicationController
  before_action :set_submission, only: [:edit, :update]

  def edit
  end

  def update
    @submission.update_attributes(submission_params)
    redirect_to replies_path
  end

private

  def submission_params
    params.require(:submission).permit(:rating, :achievements, :improvements).
      merge(status: params[:autosave].present? ? :started : :submitted)
  end

  def set_submission
    @submission = scope.where(id: params[:id]).first
  end

  def scope
    current_user.submissions
  end
end
