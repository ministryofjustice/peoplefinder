require 'rails_helper'

feature 'Acceptance maintenance' do
  scenario 'Accept a feedback request' do
    visit token_url(create(:review_token))

    select 'accept', from: 'Status'
    click_button 'Update'

    expect(Review.last).to be_accepted
  end

  scenario 'Decline a feedback request' do
    visit token_url(create(:review_token))

    select 'decline', from: 'Status'
    click_button 'Update'

    expect(Review.last).to be_declined
  end
end
