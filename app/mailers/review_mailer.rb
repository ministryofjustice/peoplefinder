class ReviewMailer < ActionMailer::Base
  default from: Rails.configuration.noreply_email

  def feedback_request(review, token)
    @recipient_name = review.author_name
    @subject_name = review.subject.name
    @invitation_message = review.invitation_message
    @token = token
    mail to: review.author_email
  end

  def request_declined(review, token)
    @recipient_name = review.subject.name
    @decliner_name = review.author.name
    @reason = review.reason_declined
    @token = token
    mail to: review.subject.email
  end
end
