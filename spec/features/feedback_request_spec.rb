require 'rails_helper'

feature 'Feedback request' do
  let(:acceptance) { create(:acceptance) }
  let(:subject_name) { review.subject.name }
  let(:token) { create(:token, review: acceptance) }

  before do
    visit token_url(token)
  end

  scenario 'Accept a feedback request' do
    click_link 'Accept / Reject'
    choose 'accepted'
    click_button 'Update'
    expect(Acceptance.last).to be_accepted
  end

  scenario 'Decline a feedback request' do
    click_link 'Accept / Reject'
    choose 'declined'
    click_button 'Update'

    expect(Acceptance.last).to be_declined
  end
end
