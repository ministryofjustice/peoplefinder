require 'rails_helper'

RSpec.describe FeedbackSubmissionNotification do
  it 'sends a notification that feedback has been submitted' do
    review = create(:review)
    token = double(:token)
    mail = double(:mail)

    expect(review.subject.tokens).to receive(:create!).and_return(token)
    expect(ReviewMailer).to receive(:feedback_submission).with(review, token).
      and_return(mail)
    expect(mail).to receive(:deliver)

    described_class.new(review).notify
  end
end
