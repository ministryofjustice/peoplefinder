require 'rails_helper'

feature 'Token Authentication' do
  before { create(:group) }

  scenario 'trying to log in with an invalid email address' do
    visit new_token_path
    fill_in 'Email', with: 'Bob'
    expect { click_button 'Login' }.not_to change { ActionMailer::Base.deliveries.count }
    expect(page).to have_text('Please enter a valid email address')
  end

  scenario 'trying to log in with a non-whitelisted email address domain' do
    visit new_token_path
    fill_in 'Email', with: 'james@abscond.org'
    expect { click_button 'Login' }.not_to change { ActionMailer::Base.deliveries.count }
    expect(page).to have_text('You need to log in with a valid MOJ email address')
  end

  scenario 'accurate email' do
    visit new_token_path
    fill_in 'Email', with: 'james.darling@digital.justice.gov.uk'
    expect { click_button 'Login' }.to change { ActionMailer::Base.deliveries.count }.by(1)
    expect(page).to have_text('Please check your email for your login link')

    expect(last_email.to).to eql(['james.darling@digital.justice.gov.uk'])
    expect(last_email.body.encoded).to have_text(token_url(Token.last))
  end

  scenario 'following valid link from email' do
    token = create(:token)
    visit token_path(token)
    expect(page).to have_text("Logged in as #{ token.user_email }")
  end

  scenario 'following a link from an inadequate profile email' do
    person = create(:person, email: 'test.user@digital.justice.gov.uk')
    ReminderMailer.inadequate_profile(person).deliver

    visit links_in_email(last_email).last
    within('h1') do
      expect(page).to have_text('Edit profile')
    end
  end

  scenario 'logging out' do
    token_log_in_as('james.darling@digital.justice.gov.uk')
    visit '/'
    expect(page).to have_text('james.darling@digital.justice.gov.uk')
    click_link 'Log out'
    expect(page).not_to have_text('james.darling@digital.justice.gov.uk')
    expect(page).to have_text('log in to continue')
  end
end
