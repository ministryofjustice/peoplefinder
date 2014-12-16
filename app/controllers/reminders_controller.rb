class RemindersController < ApplicationController
  before_action :set_review, only: [:create]

  def create
    return forbidden unless @review

    @reminder = FeedbackRequestNotification.new(@review)
    sent = @reminder.notify
    notice :reminder_sent if sent
    redirect_to reviews_path
  end

private

  def reminder_params
    params.require(:review).permit(:review_id)
  end

  def set_review
    @review = scope.where(id: reminder_params[:review_id]).first
  end

  def scope
    current_user.reviews
  end
end
