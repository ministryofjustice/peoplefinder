require 'rails_helper'

feature 'Review period' do

  let(:password) { generate(:password) }
  let(:user) { create(:admin_user) }
  let(:identity) { create(:identity, password: password, user: user) }

  scenario 'Closing the review period' do
    visit admin_path
    log_in identity.username, password
    visit admin_path

    expect(page).to have_text('Review period is currently open')
    click_button 'Close review period'

    expect(page).to have_text('Review period is currently closed')
    expect(ReviewPeriod.instance).to be_closed

    click_button 'Open review period'
    expect(ReviewPeriod.instance).to be_open
  end
end
