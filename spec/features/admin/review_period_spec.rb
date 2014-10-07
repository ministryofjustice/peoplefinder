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

  scenario 'Sending introduction emails' do
    participant = create(:user)

    visit admin_path

    click_button 'Send introduction emails'

    mail = last_email
    expect(mail.to).to include(participant.email)
    expect(mail.subject).to eq('360 feedback process has begun')
  end

  scenario 'Sending review period closure emails' do
    participant = create(:user)

    visit admin_path

    click_button 'Close review period'
    click_button 'Send review period closure emails'

    mail = last_email
    expect(mail.to).to include(participant.email)
    expect(mail.subject).to eq('360 feedback process has closed')
  end
end
