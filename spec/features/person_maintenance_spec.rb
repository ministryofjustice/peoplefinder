require 'rails_helper'

feature "Person maintenance" do
  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario "Creating a person with a complete profile", js: true do
    create(:group, name: 'Digital')

    javascript_log_in
    visit new_person_path
    fill_in_new_profile_details

    click_button "Create"
    check_creation_of_profile_details
  end

  scenario 'Creating an invalid person' do
    visit new_person_path
    click_button "Create"
    expect(page).to have_text('Please review the problems')
    within('div.person_surname') do
      expect(page).to have_text('can\'t be blank')
    end
  end

  scenario 'Creating a person with an identical name', js: true do
    create(:group, name: 'Digital')
    create(:person, given_name: person_attributes[:given_name],
                    surname: person_attributes[:surname])

    javascript_log_in
    visit new_person_path
    fill_in_new_profile_details

    click_button 'Create'

    expect(page).to have_text('1 result found')
    click_button 'Continue'
    check_creation_of_profile_details
    expect(Person.where(surname: person_attributes[:surname]).count).to eql(2)
  end

  scenario 'Cancelling creation of a person with an identical name' do
    create(:person, given_name: person_attributes[:given_name],
                    surname: person_attributes[:surname])
    visit new_person_path

    fill_in 'First name', with: person_attributes[:given_name]
    fill_in 'Surname', with: person_attributes[:surname]
    click_button 'Create'

    click_link 'Return to home page'
    expect(Person.where(surname: person_attributes[:surname]).count).to eql(1)
  end

  scenario 'Editing a person and giving them a name that already exists' do
    create(:person, given_name: person_attributes[:given_name],
                    surname: person_attributes[:surname])
    person = create(:person, given_name: 'Bobbie', surname: 'Browne')
    visit edit_person_path(person)

    fill_in 'First name', with: person_attributes[:given_name]
    fill_in 'Surname', with: person_attributes[:surname]
    click_button 'Update'

    click_button 'Continue'
    expect(Person.where(surname: person_attributes[:surname]).count).to eql(2)
  end

  scenario 'Deleting a person' do
    person = create(:person)
    visit edit_person_path(person)
    click_link('Delete this profile')
    expect { Person.find(person) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario 'Allow deletion of a person even when there are memberships' do
    membership = create(:membership)
    person = membership.person
    visit edit_person_path(person)
    click_link('Delete this profile')
    expect { Membership.find(membership) }.to raise_error(ActiveRecord::RecordNotFound)
    expect { Person.find(person) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario 'Editing a person' do
    visit person_path(create(:person, person_attributes))
    click_link 'Edit this profile'

    fill_in 'First name', with: 'Jane'
    fill_in 'Surname', with: 'Doe'
    click_button 'Update'

    expect(page).to have_content("Updated Jane Doe’s profile")
    within('h1') do
      expect(page).to have_text('Jane Doe')
    end
  end

  scenario 'Editing an invalid person' do
    visit person_path(create(:person, person_attributes))
    click_link 'Edit this profile'
    fill_in 'Surname', with: ''
    click_button 'Update'

    expect(page).to have_text('Please review the problems')
    within('div.person_surname') do
      expect(page).to have_text('can\'t be blank')
    end
  end

  scenario 'Adding a profile image' do
    visit new_person_path
    fill_in 'Surname', with: person_attributes[:surname]
    attach_file 'person[image]', sample_image
    expect(page).not_to have_link('Crop image')
    click_button 'Create'

    person = Person.find_by_surname(person_attributes[:surname])
    visit person_path(person)
    expect(page).to have_css("img[src*='#{person.image.medium}']")

    visit edit_person_path(person)
    expect(page).to have_link('Crop image', edit_person_image_path(person))
  end

  context 'Viewing my own profile' do
    let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }

    scenario 'when it is complete' do
      complete_profile!(person)
      visit person_path(person)
      expect(page).not_to have_text('Profile completeness')
    end

    scenario 'when it is incomplete' do
      visit person_path(person)
      expect(page).to have_text('Profile completeness')
    end
  end

  context 'Viewing another person\'s profile' do
    let(:person) { create(:person, email: 'someone.else@digital.justice.gov.uk') }

    scenario 'when it is complete' do
      complete_profile!(person)
      visit person_path(person)
      expect(page).not_to have_text('Profile completeness')
    end

    scenario 'when it is incomplete and there is no email address' do
      person.update_attributes email: nil
      visit person_path(person)
      expect(page).not_to have_text('Profile completeness')
      expect(page).not_to have_link('Ask the person to update their details')
    end

    scenario 'when it is incomplete, I request more information' do
      visit person_path(person)
      expect(page).not_to have_text('Profile completeness')

      click_link('Ask the person to update their details')
      expect(page).to have_link('Cancel', person_path(person))

      within('h1') do
        expect(page).to have_text(person.name)
      end

      fill_in 'information_request_message', with: 'Hello Bob'
      expect { click_button 'Submit' }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(last_email).to have_text('Hello Bob')
      expect(last_email.to).to include(person.email)
      expect(last_email.subject).to eql('Request to update your People Finder profile')
      check_email_has_token_link_to(person)
      expect(page).to have_text("Your message has been sent to #{ person.name }")
    end
  end

  scenario 'UI elements on the new/edit pages' do
    visit new_person_path
    expect(page).not_to have_selector('.search-box')
    expect(page).to have_text('You are currently editing this page')

    fill_in 'Surname', with: person_attributes[:surname]
    click_button 'Create'
    expect(page).to have_selector('.search-box')
    expect(page).not_to have_text('You are currently editing this page')

    click_link 'Edit this profile'
    expect(page).not_to have_selector('.search-box')
    expect(page).to have_text('You are currently editing this page')
  end

  scenario 'Cancelling an edit' do
    person = create(:person)
    visit edit_person_path(person)
    expect(page).to have_link('Cancel', href: person_path(person))
  end

  scenario 'Cancelling a new form' do
    visit new_person_path
    expect(page).to have_link('Cancel', href: 'javascript:history.back()')
  end
end

def person_attributes
  {
    given_name: 'Marco',
    surname: 'Polo',
    email: 'marco.polo@example.com',
    primary_phone_number: '+44-208-123-4567',
    secondary_phone_number: '07777777777',
    location: 'MOJ / Petty France / London',
    description: 'Lorem ipsum dolor sit amet...'
  }
end

def complete_profile!(person)
  person.update_attributes(person_attributes.except(:email))
  person.groups << create(:group)
end

def fill_in_new_profile_details
  fill_in 'First name', with: person_attributes[:given_name]
  fill_in 'Surname', with: person_attributes[:surname]
  click_in_org_browser 'Digital'
  fill_in 'Email', with: person_attributes[:email]
  fill_in 'Primary phone number', with: person_attributes[:primary_phone_number]
  fill_in 'Any other phone number', with: person_attributes[:secondary_phone_number]
  fill_in 'Location', with: person_attributes[:location]
  fill_in 'Notes', with: person_attributes[:description]
  uncheck('Monday')
  uncheck('Friday')
  attach_file 'person[image]', sample_image
end

def check_creation_of_profile_details
  click_button 'Update Image'

  within('h1') do
    expect(page).to have_text(person_attributes[:given_name] + ' ' + person_attributes[:surname])
  end
  expect(page).to have_text(person_attributes[:email])
  expect(page).to have_text(person_attributes[:primary_phone_number])
  expect(page).to have_text(person_attributes[:secondary_phone_number])
  expect(page).to have_text(person_attributes[:location])
  expect(page).to have_text(person_attributes[:description])

  within('ul.working_days') do
    expect(page).to_not have_selector("li.active[alt='Monday']")
    expect(page).to have_selector("li.active[alt='Tuesday']")
    expect(page).to have_selector("li.active[alt='Wednesday']")
    expect(page).to have_selector("li.active[alt='Thursday']")
    expect(page).to_not have_selector("li.active[alt='Friday']")
    expect(page).to_not have_selector("li.active[alt='Saturday']")
    expect(page).to_not have_selector("li.active[alt='Sunday']")
  end

  expect(page).to have_css("img[src*='medium_placeholder.png']")
end
