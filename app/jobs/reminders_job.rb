class RemindersJob < ActiveJob::Base
  queue_as :reminders

  FEEDBACK_TO_RECEIVE_DAYS = 8
  FEEDBACK_TO_GIVE_DAYS = 7
  CLOSING_SOON_DAYS = 9

  def perform
    logger.info "Running RemindersJob with #{days_left} days left"

    # Note: we don't use case here because the constants are not required to
    # be unique.
    if days_left == FEEDBACK_TO_GIVE_DAYS
      notify_people_with_feedback_to_give
    end
    if days_left == FEEDBACK_TO_RECEIVE_DAYS
      notify_people_with_feedback_to_receive
    end
    if days_left == CLOSING_SOON_DAYS
      notify_recipients
    end
  end

private

  def days_left
    @days_left ||= ReviewPeriod.days_left
  end

  def notify_people_with_feedback_to_give
    reviews = Review.open.to_a.uniq(&:author_email)
    logger.info "Sending #{reviews.count} Feedback Not Given notification(s)"
    reviews.each do |review|
      FeedbackNotGivenNotification.new(review).notify
    end
  end

  def notify_people_with_feedback_to_receive
    users = User.with_feedback_not_received.uniq
    logger.info "Sending #{users.count} Feedback Not Received notification(s)"
    users.each do |user|
      FeedbackNotReceivedNotification.new(user).notify
    end
  end

  def notify_recipients
    users = User.recipients
    logger.info "Sending #{users.count} Closing Soon notification(s)"
    users.each do |user|
      ClosingSoonNotification.new(user).notify
    end
  end
end
