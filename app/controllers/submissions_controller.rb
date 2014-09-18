class SubmissionsController < ApplicationController
  before_action :set_submission, only: [:edit, :update]

  def edit
  end

  def update
    if @submission.update_attributes(submission_params)
      notice :updated unless autosave?
      redirect_to replies_path
    else
      error :update_error
      render :edit
    end
  end

private

  def submission_params
    params.require(:submission).permit(Review::RATING_FIELDS,
      :leadership_comments, :how_we_work_comments).
      merge(status: autosave? ? :started : :submitted)
  end

  def autosave?
    params[:autosave].present?
  end

  def set_submission
    @submission = scope.where(id: params[:id]).first
  end

  def scope
    current_user.submissions
  end
end
