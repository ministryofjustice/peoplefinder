class RemindersController < ApplicationController
  before_action :set_review, only: [:create]

  def create
    return forbidden unless @review

    @reminder = FeedbackRequest.new(@review)

    notice = @reminder.send ? 'A reminder has been sent' : nil
    redirect_to reviews_path, notice: notice
  end

private

  def reminder_params
    params.require(:review).permit(:review_id)
  end

  def set_review
    @review = scope.reviews_received.
                    where(id: reminder_params[:review_id]).first
  end

  def scope
    current_user
  end
end
