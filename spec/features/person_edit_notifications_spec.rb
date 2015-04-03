require 'rails_helper'

feature 'Person edit notifications' do
  include ActiveJobHelper

  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }
  before do
    omni_auth_log_in_as(person.email)
  end

  scenario 'Creating a person with different email' do
    visit new_person_path

    fill_in 'First name', with: 'Bob'
    fill_in 'Surname', with: 'Smith'
    fill_in 'Email', with: 'bob.smith@digital.justice.gov.uk'
    expect { click_button 'Save' }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(last_email.subject).to eq('A new profile on MOJ People Finder has been created for you')

    check_email_to_and_from
    check_email_has_profile_link(Person.where(email: 'bob.smith@digital.justice.gov.uk').first)
  end

  scenario 'Deleting a person with different email' do
    person = create(:person, email: 'bob.smith@digital.justice.gov.uk')
    visit edit_person_path(person)
    expect { click_link('Delete this profile') }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(last_email.subject).to eq('Your profile on MOJ People Finder has been deleted')
    check_email_to_and_from
  end

  scenario 'Deleting a person with same email' do
    visit edit_person_path(person)
    expect { click_link('Delete this profile') }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Editing a person with different email' do
    person = create(:person, given_name: 'Bob', surname: 'Smith', email: 'bob.smith@digital.justice.gov.uk')
    visit person_path(person)
    click_link 'Edit this profile'
    fill_in 'Surname', with: 'Smelly Pants'
    expect { click_button 'Save' }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(last_email.subject).to eq('Your profile on MOJ People Finder has been edited')

    check_email_to_and_from
    check_email_has_profile_link(person)
  end

  scenario 'Editing a person with same email' do
    visit person_path(person)
    click_link 'Edit this profile'
    fill_in 'Surname', with: 'Smelly Pants'
    expect { click_button 'Save' }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Verifying the link to bob that is render in the emails' do
    bob = create(:person, email: 'bob@digital.justice.gov.uk', surname: 'bob')
    visit token_url(Token.for_person(bob), desired_path: person_path(bob))

    within('h1') do
      expect(page).to have_text('bob')
    end
  end

  def check_email_to_and_from
    expect(last_email.to).to eql(['bob.smith@digital.justice.gov.uk'])
    expect(last_email.body.encoded).to match('test.user@digital.justice.gov.uk')
  end
end
