require 'rails_helper'

feature 'Feedback request maintenance' do
  let(:feedback_request) { create(:feedback_request) }
  let(:subject_name) { review.subject.name }
  let(:token) { create(:token, review: feedback_request) }

  before do
    visit token_url(token)
  end

  scenario 'Accept a feedback request' do
    expect(page).to have_text 'You have feedback requests from 1 colleague:'
    choose 'Accept'
    click_button 'Update'

    expect(page).to have_text 'You have accepted 360 feedback requests for 1 colleague:'
  end

  scenario 'Reject a feedback request' do
    choose 'Reject'
    click_button 'Update'

    expect(FeedbackRequest.last).to be_rejected
  end
end
