class ReviewMailer < ActionMailer::Base
  default from: Rails.configuration.noreply_email

  def feedback_request(review, token)
    @recipient_name = review.author_name
    @subject_name = review.subject.name
    @token = token
    mail to: review.author_email, subject: 'Request for feedback'
  end
end
