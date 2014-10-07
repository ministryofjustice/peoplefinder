require 'rails_helper'

feature 'Review period' do
  let(:user) { create(:admin_user) }

  before do
    log_in_as user
  end

  scenario 'Closing and re-opening the review period' do
    visit admin_path

    expect(page).to have_text('Review period is currently open')
    click_button 'Close review period'

    expect(page).to have_text('Review period is currently closed')
    expect(ReviewPeriod.instance).to be_closed

    click_button 'Open review period'
    expect(ReviewPeriod.instance).to be_open
  end
end
