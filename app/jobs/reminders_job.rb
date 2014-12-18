class RemindersJob < ActiveJob::Base
  queue_as :reminders

  FEEDBACK_TO_RECEIVE_DAYS = 8
  FEEDBACK_TO_GIVE_DAYS = 7

  def perform
    if ReviewPeriod.days_left == FEEDBACK_TO_GIVE_DAYS
      notify_people_with_feedback_to_give
    end
    if ReviewPeriod.days_left == FEEDBACK_TO_RECEIVE_DAYS
      notify_people_with_feedback_to_receive
    end
  end

private

  def notify_people_with_feedback_to_give
    Review.open.to_a.uniq(&:author_email).each do |review|
      FeedbackNotGivenNotification.new(review).notify
    end
  end

  def notify_people_with_feedback_to_receive
    User.with_feedback_not_received.uniq.each do |user|
      FeedbackNotReceivedNotification.new(user).notify
    end
  end
end
