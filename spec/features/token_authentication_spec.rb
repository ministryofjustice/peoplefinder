require 'rails_helper'

feature 'Token Authentication' do
  before { create(:group) }

  scenario 'trying to log in with an invalid email address' do
    visit '/'
    fill_in 'token_user_email', with: 'Bob'
    expect { click_button 'Log in' }.not_to change { ActionMailer::Base.deliveries.count }
    expect(page).to have_text('Email address is not formatted correctly')
  end

  scenario 'trying to log in with a non-whitelisted email address domain' do
    visit '/'
    fill_in 'token_user_email', with: 'james@abscond.org'
    expect { click_button 'Log in' }.not_to change { ActionMailer::Base.deliveries.count }
    expect(page).to have_text('Email address is not valid')
  end

  scenario 'accurate email' do
    visit '/'
    fill_in 'token_user_email', with: 'james.darling@digital.justice.gov.uk'
    expect { click_button 'Log in' }.to change { ActionMailer::Base.deliveries.count }.by(1)
    expect(page).to have_text('Check your email for a link to log in')

    expect(last_email.to).to eql(['james.darling@digital.justice.gov.uk'])
    expect(last_email.body.encoded).to have_text(token_url(Token.last))
  end

  scenario 'following valid link from email' do
    token = create(:token)
    visit token_path(token)
    expect(page).to have_link("Logged in as")
  end

  scenario 'logging in and displaying a link to my profile' do
    person = create(:person, surname: 'Bob', email: 'test.user@digital.justice.gov.uk')
    token = Token.for_person(person)
    visit token_path(token)
    expect(page).to have_link("Logged in as Bob", href: person_path(person))
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
    expect(page).to have_text('james darling')
    click_link 'Log out'
    expect(page).not_to have_text('james.darling@digital.justice.gov.uk')
    expect(page).to have_text('Log in to the people finder')
  end
end
