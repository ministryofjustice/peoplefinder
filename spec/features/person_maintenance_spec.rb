require 'rails_helper'

feature "Person maintenance" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario "Creating a person with a complete profile" do
    group = create(:group, name: 'Digital')
    visit new_person_path
    p = person_attributes
    fill_in 'Given name', with: p[:given_name]
    fill_in 'Surname', with: p[:surname]
    select 'Digital', from: 'Group'
    fill_in 'Email', with: p[:email]
    fill_in 'Phone', with: p[:phone]
    fill_in 'Mobile', with: p[:mobile]
    fill_in 'Location', with: p[:location]
    fill_in 'Description', with: p[:description]
    uncheck('Monday')
    uncheck('Friday')
    click_button "Create person"

    expect(page).to have_content("Created Marco Polo’s profile")

    within('h1') do
      expect(page).to have_text(p[:given_name] + ' ' + p[:surname])
    end
    expect(page).to have_text(p[:email])
    expect(page).to have_text(p[:phone])
    expect(page).to have_text('Mob: ' + p[:mobile])
    expect(page).to have_text(p[:location])
    expect(page).to have_text(p[:description])

    within ('ul.working_days') do
      expect(page).to_not have_selector("li.active[alt='Monday']")
      expect(page).to have_selector("li.active[alt='Tuesday']")
      expect(page).to have_selector("li.active[alt='Wednesday']")
      expect(page).to have_selector("li.active[alt='Thursday']")
      expect(page).to_not have_selector("li.active[alt='Friday']")
      expect(page).to_not have_selector("li.active[alt='Saturday']")
      expect(page).to_not have_selector("li.active[alt='Sunday']")
    end

    expect(page).not_to have_text('Profile completeness')
  end

  scenario 'Creating an invalid person' do
    visit new_person_path
    click_button "Create person"
    expect(page).to have_text('Please review the problems')
    within('div.person_surname') do
      expect(page).to have_text('can\'t be blank')
    end
  end

  scenario 'Deleting a person' do
    person = create(:person)
    visit edit_person_path(person)
    click_link('Delete')

    expect(page).to have_content("Deleted #{person}’s profile")

    expect { Person.find(person) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario 'Prevent deletion of a person that has memberships' do
    membership = create(:membership)
    person = membership.person
    visit edit_person_path(person)
    expect(page).not_to have_link('Delete')
  end

  scenario 'Editing a person' do
    visit person_path(create(:person, person_attributes))
    click_link 'Edit this page'
    fill_in 'Given name', with: 'Jane'
    fill_in 'Surname', with: 'Doe'
    click_button 'Update person'

    expect(page).to have_content("Updated Jane Doe’s profile")

    within('h1') do
      expect(page).to have_text('Jane Doe')
    end
  end

  scenario 'Editing an invalid person' do
    visit person_path(create(:person, person_attributes))
    click_link 'Edit this page'
    fill_in 'Surname', with: ''
    click_button 'Update person'

    expect(page).to have_text('Please review the problems')
    within('div.person_surname') do
      expect(page).to have_text('can\'t be blank')
    end
  end

  scenario 'Adding a profile image' do
    visit new_person_path
    fill_in 'Surname', with: person_attributes[:surname]
    attach_file 'person[image]', sample_image
    click_button 'Create person'

    person = Person.find_by_surname(person_attributes[:surname])
    visit person_path(person)
    expect(page).to have_css("img[src*='#{person.image.medium}']")
  end

  scenario 'Viewing a person with an incomplete profile' do
    visit person_path(create(:person))
    expect(page).to have_text('Profile completeness')
  end
end

def person_attributes
  {
    given_name: 'Marco',
    surname: 'Polo',
    email: 'marco.polo@example.com',
    phone: '+44-208-123-4567',
    mobile: '07777777777',
    location: 'MOJ / Petty France / London',
    description: 'Lorem ipsum dolor sit amet...'
  }
end
