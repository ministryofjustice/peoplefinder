require 'rails_helper'

feature 'Person edit notifications' do
  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Creating a person with different email' do
    visit new_person_path

    fill_in 'First name', with: 'Bob'
    fill_in 'Surname', with: 'Smith'
    fill_in 'Email', with: 'bob.smith@digital.justice.gov.uk'
    expect { click_button 'Create' }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(last_email.subject).to eq('A new profile on MOJ People Finder has been created for you')

    check_email_to_and_from
    check_email_has_token_link_to(Peoplefinder::Person.last)
  end

  scenario 'Creating a person with same email' do
    visit new_person_path

    fill_in 'First name', with: 'Bob'
    fill_in 'Surname', with: 'Smith'
    fill_in 'Email', with: 'test.user@digital.justice.gov.uk'
    expect { click_button 'Create' }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Creating a person with email from invalid domain' do
    visit new_person_path

    fill_in 'Surname', with: 'Smith'
    fill_in 'Email', with: 'test.user@something-else.example.com'
    expect { click_button 'Create' }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Creating a person with invalid email' do
    visit new_person_path

    fill_in 'First name', with: 'Bob'
    fill_in 'Surname', with: 'Smith'
    fill_in 'Email', with: 'test.user'
    expect { click_button 'Create' }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Creating a person with nil email' do
    visit new_person_path

    fill_in 'First name', with: 'Bob'
    fill_in 'Surname', with: 'Smith'
    expect { click_button 'Create' }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Deleting a person with different email' do
    person = create(:person, email: 'bob.smith@digital.justice.gov.uk')
    visit edit_person_path(person)
    expect { click_link('Delete this profile') }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(last_email.subject).to eq('Your profile on MOJ People Finder has been deleted')
    check_email_to_and_from
  end

  scenario 'Deleting a person with same email' do
    person = create(:person, email: 'test.user@digital.justice.gov.uk')
    visit edit_person_path(person)
    expect { click_link('Delete this profile') }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Deleting a person with email from invalid domain' do
    person = create(:person, email: 'test.user@something-else.example.com')
    visit edit_person_path(person)
    expect { click_link('Delete this profile') }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Deleting a person with invalid email' do
    person = create(:person, email: 'test.user')
    visit edit_person_path(person)
    expect { click_link('Delete this profile') }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Deleting a person with nil email' do
    person = create(:person, email: nil)
    visit edit_person_path(person)
    expect { click_link('Delete this profile') }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Editing a person with different email' do
    person = create(:person, given_name: 'Bob', surname: 'Smith', email: 'bob.smith@digital.justice.gov.uk')
    visit person_path(person)
    click_link 'Edit this profile'
    fill_in 'Surname', with: 'Smelly Pants'
    expect { click_button 'Update' }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(last_email.subject).to eq('Your profile on MOJ People Finder has been edited')

    check_email_to_and_from
    check_email_has_token_link_to(person)
  end

  scenario 'Editing a person with an email from invalid domain' do
    person = create(:person, given_name: 'Bob', surname: 'Smith', email: 'bob.smith@something-else.example.com')
    visit person_path(person)
    click_link 'Edit this profile'
    fill_in 'Surname', with: 'Smelly Pants'
    expect { click_button 'Update' }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Editing a person with same email' do
    person = create(:person, given_name: 'Bob', surname: 'Smith', email: 'test.user@digital.justice.gov.uk')
    visit person_path(person)
    click_link 'Edit this profile'
    fill_in 'Surname', with: 'Smelly Pants'
    expect { click_button 'Update' }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Editing a person with nil email' do
    person = create(:person, given_name: 'Bob', surname: 'Smith', email: nil)
    visit person_path(person)
    click_link 'Edit this profile'
    fill_in 'Surname', with: 'Smelly Pants'
    expect { click_button 'Update' }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Editing a person with invalid email' do
    person = create(:person, given_name: 'Bob', surname: 'Smith', email: 'test.user')
    visit person_path(person)
    click_link 'Edit this profile'
    fill_in 'Surname', with: 'Smelly Pants'
    expect { click_button 'Update' }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Editing a person from same email to different email' do
    person = create(:person, given_name: 'Bob', surname: 'Smith', email: 'test.user@digital.justice.gov.uk')
    visit person_path(person)
    click_link 'Edit this profile'
    fill_in 'Email', with: 'bob.smith@digital.justice.gov.uk'
    expect { click_button 'Update' }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(last_email.subject).to eq('This email address has been added to a profile on MOJ People Finder')

    check_email_to_and_from
    check_email_has_token_link_to(person)
  end

  scenario 'Editing a person from different email to same email' do
    person = create(:person, given_name: 'Bob', surname: 'Smith', email: 'bob.smith@digital.justice.gov.uk')
    visit person_path(person)
    click_link 'Edit this profile'
    fill_in 'Email', with: 'test.user@digital.justice.gov.uk'
    expect { click_button 'Update' }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(last_email.subject).to eq('This email address has been removed from a profile on MOJ People Finder')

    check_email_to_and_from
    check_email_has_token_link_to(person)
  end

  scenario 'Editing a person from different email to different email' do
    person = create(:person, given_name: 'Bob', surname: 'Smith', email: 'bob.smith@digital.justice.gov.uk')
    visit person_path(person)
    click_link 'Edit this profile'
    fill_in 'Email', with: 'bob.smithe@digital.justice.gov.uk'
    expect { click_button 'Update' }.to change { ActionMailer::Base.deliveries.count }.by(2)
  end

  scenario 'Editing a person from invalid email to invalid email' do
    person = create(:person, given_name: 'Bob', surname: 'Smith', email: 'bob.smith')
    visit person_path(person)
    click_link 'Edit this profile'
    fill_in 'Email', with: 'test.user'
    expect { click_button 'Update' }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Verifying the link to bob that is render in the emails' do
    bob = create(:person, email: 'bob@digital.justice.gov.uk', surname: 'bob')
    visit token_url(Peoplefinder::Token.for_person(bob), desired_path: person_path(bob))

    within('h1') do
      expect(page).to have_text('bob')
    end
  end

  def check_email_to_and_from
    expect(last_email.to).to eql(['bob.smith@digital.justice.gov.uk'])
    expect(last_email.body.encoded).to match('test.user@digital.justice.gov.uk')
  end

  def check_email_has_token_link_to(person)
    expect(last_email.body.encoded).to match("http.*tokens\/#{ Peoplefinder::Token.last.to_param }.*?desired_path=%2Fpeople%2F*#{ person.to_param }")
  end
end
