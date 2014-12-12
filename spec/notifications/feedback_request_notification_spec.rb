require 'rails_helper'

RSpec.describe FeedbackRequestNotification do
  it 'sends a feedback request reminder to the user' do
    review = create(:review)
    token = double(:token)
    mail = double(:mail)

    expect(review.tokens).to receive(:create!).and_return(token)
    expect(ReviewMailer).to receive(:feedback_request).with(review, token).
      and_return(mail)
    expect(mail).to receive(:deliver)

    described_class.new(review).notify
  end
end
