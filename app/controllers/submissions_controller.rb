class SubmissionsController < ApplicationController
  before_action :set_submission, only: [:edit, :update]
  before_action :suppress_tabs

  def edit
  end

  def update
    if @submission.update(submission_params)
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
    @submission = Submission.new(scope.find(params[:id]))
  end

  def scope
    current_user.replies.editable
  end
end
