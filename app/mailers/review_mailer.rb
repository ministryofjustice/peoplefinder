class ReviewMailer < ActionMailer::Base
  helper :application

  default from: Rails.configuration.noreply_email

  def feedback_request(review, token)
    @recipient_name = review.author_name
    @subject_name = review.subject.name
    @invitation_message = review.invitation_message
    @token = token
    sender = formatted_address(review.subject_name, review.subject_email)
    mail to: review.author_email
  end

  def request_declined(review, token)
    @recipient_name = review.subject.name
    @decliner_name = review.author_name
    @token = token
    @reason = review.reason_declined
    sender = formatted_address(review.author_name, review.author_email)
    mail to: review.subject_email
  end

  def feedback_submission(review, token)
    @recipient_name = review.subject.name
    @submitter_name = review.author_name
    @token = token
    sender = formatted_address(review.author_name, review.author_email)
    mail to: review.subject_email
  end

private

  def formatted_address(name, email_address)
    # See http://stackoverflow.com/a/8106387
    Mail::Address.new(email_address).tap { |a|
      a.display_name = name.dup if name
    }.format
  end
end
