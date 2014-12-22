class ReviewMailer < ActionMailer::Base
  helper :application

  default from: Rails.configuration.noreply_email

  def feedback_request(review, token)
    @recipient_name = review.author_name
    @subject_name = review.subject.name
    @invitation_message = review.invitation_message
    @token = token
    mail to: review.author_email, from: review.subject_email
  end

  def request_declined(review, token)
    @recipient_name = review.subject.name
    @decliner_name = review.author_name
    @token = token
    @reason = review.reason_declined
    mail to: review.subject_email, from: review.author_email
  end

  def feedback_submission(review, token)
    @recipient_name = review.subject.name
    @submitter_name = review.author_name
    @token = token
    mail to: review.subject_email, from: review.author_email
  end
end
