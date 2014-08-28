require 'rails_helper'

feature 'Submissions maintenance' do
  let(:review) { create(:review) }
  let(:subject_name) { review.subject.name }
  let(:token) { create(:token, review: review) }

  before do
    visit token_url(token)
  end

  scenario 'Accept a feedback request' do
    accept_feedback_request
    expect(Review.last).to be_accepted
  end

  scenario 'Decline a feedback request' do
    click_link 'Accept / Reject'
    choose 'declined'
    click_button 'Update'

    expect(Review.last).to be_declined
  end

  def accept_feedback_request
    click_link 'Accept / Reject'
    choose 'accepted'
    click_button 'Update'
  end
end
