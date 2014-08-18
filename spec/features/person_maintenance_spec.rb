require 'rails_helper'

feature "Person maintenance" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario "Creating a person with a complete profile" do
    create(:group, name: 'Digital')
    visit new_person_path
    p = person_attributes
    fill_in 'First name', with: p[:given_name]
    fill_in 'Surname', with: p[:surname]
    select 'Digital', from: 'Team'
    fill_in 'Email', with: p[:email]
    fill_in 'Primary phone number', with: p[:primary_phone_number]
    fill_in 'Any other phone number', with: p[:secondary_phone_number]
    fill_in 'Location', with: p[:location]
    fill_in 'Notes', with: p[:description]
    uncheck('Monday')
    uncheck('Friday')
    click_button "Create"

    expect(page).to have_content("Created Marco Polo’s profile")

    within('h1') do
      expect(page).to have_text(p[:given_name] + ' ' + p[:surname])
    end
    expect(page).to have_text(p[:email])
    expect(page).to have_text(p[:primary_phone_number])
    expect(page).to have_text(p[:secondary_phone_number])
    expect(page).to have_text(p[:location])
    expect(page).to have_text(p[:description])

    within('ul.working_days') do
      expect(page).to_not have_selector("li.active[alt='Monday']")
      expect(page).to have_selector("li.active[alt='Tuesday']")
      expect(page).to have_selector("li.active[alt='Wednesday']")
      expect(page).to have_selector("li.active[alt='Thursday']")
      expect(page).to_not have_selector("li.active[alt='Friday']")
      expect(page).to_not have_selector("li.active[alt='Saturday']")
      expect(page).to_not have_selector("li.active[alt='Sunday']")
    end
  end

  scenario 'Creating an invalid person' do
    visit new_person_path
    click_button "Create"
    expect(page).to have_text('Please review the problems')
    within('div.person_surname') do
      expect(page).to have_text('can\'t be blank')
    end
  end

  pending do
    scenario 'Creating a person with an identical name' do
      create(:person, given_name: 'Bo', surname: 'Diddley')
      visit new_person_path

      fill_in 'First name', with: 'Bo'
      fill_in 'Surname', with: 'Diddley'
      click_button 'Create'

      click_button 'Continue'
      expect(page).to have_content("Created Bo Diddley’s profile")
      expect(Person.find_by_surname('Diddley').count).to eql(2)
    end
  end

  pending do
    scenario 'Cancelling creation of a person with an identical name' do
      create(:person, given_name: 'Bo', surname: 'Diddley')
      visit new_person_path

      fill_in 'First name', with: 'Bo'
      fill_in 'Surname', with: 'Diddley'
      click_button 'Create'

      click_button 'Continue'
      expect(page).to have_content("Created Bo Diddley’s profile")
      expect(Person.find_by_surname('Diddley').count).to eql(1)
    end
  end

  pending do
    scenario 'Editing a person and given them a name that already exists' do
      create(:person, given_name: 'Bo', surname: 'Diddley')
      person = create(:person, given_name: 'Bobbie', surname: 'Browne')
      visit edit_person_path(person)

      fill_in 'First name', with: 'Bo'
      fill_in 'Surname', with: 'Diddley'
      click_button 'Update'

      click_button 'Continue'
      expect(page).to have_content("Update Bo Diddley’s profile")
      expect(Person.find_by_surname('Diddley').count).to eql(2)
    end
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
    let(:person) { create(:person) }

    scenario 'when it is complete' do
      complete_profile!(person)
      visit person_path(person)
      expect(page).not_to have_text('Profile completeness')
    end

    scenario 'when it is incomplete' do
      visit person_path(person)
      expect(page).not_to have_text('Profile completeness')
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
