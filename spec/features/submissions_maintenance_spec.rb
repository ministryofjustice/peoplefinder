require 'rails_helper'

feature 'Submissions maintenance' do
  let(:review) { create(:review) }
  let(:subject_name) { review.subject.name }
  let(:token) { create(:token, review: review) }

  before do
    visit token_url(token)
  end

  scenario 'Accept a feedback request' do
    click_link subject_name

    select 'accept', from: 'Status'
    click_button 'Update'

    expect(Review.last).to be_accepted
  end

  scenario 'Decline a feedback request' do
    click_link subject_name
    select 'decline', from: 'Status'
    click_button 'Update'

    expect(Review.last).to be_declined
  end
end
