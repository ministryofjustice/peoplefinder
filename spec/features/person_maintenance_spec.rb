require 'rails_helper'

feature "Person maintenance" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario "Creating a person" do
    visit new_person_path
    p = person_attributes
    fill_in 'Given name', with: p[:given_name]
    fill_in 'Surname', with: p[:surname]
    fill_in 'Email', with: p[:email]
    fill_in 'Phone', with: p[:phone]
    fill_in 'Mobile', with: p[:mobile]
    fill_in 'Location', with: p[:location]
    fill_in 'Description', with: p[:description]
    uncheck('Works Monday')
    uncheck('Works Friday')
    click_button "Create Person"

    within('.person-name') do
      expect(page).to have_text(p[:given_name] + ' ' + p[:surname])
    end

    within('dl.person') do
      expect(page).to have_text(p[:email])
      expect(page).to have_text(p[:phone])
      expect(page).to have_text(p[:mobile])
      expect(page).to have_text(p[:location])
      expect(page).to have_text(p[:description])
    end

    within ('ul.working_days') do
      expect(page).to_not have_selector("li.active:contains('M')")
      expect(page).to have_selector("li.active:contains('T')")
      expect(page).to have_selector("li.active:contains('W')")
      expect(page).to have_selector("li.active:contains('Th')")
      expect(page).to_not have_selector("li.active:contains('F')")
    end
  end

  scenario 'Creating an invalid person' do
    visit new_person_path
    click_button "Create Person"
    expect(page).to have_text('Please review the problems')
    within('div.person_surname') do
      expect(page).to have_text('can\'t be blank')
    end
  end

  scenario 'Deleting a person softly' do
    membership = create(:membership)
    person = membership.person
    visit edit_person_path(person)
    click_link('Delete this record')

    expect { Person.find(person) }.to raise_error(ActiveRecord::RecordNotFound)
    expect { Membership.find(membership) }.to raise_error(ActiveRecord::RecordNotFound)

    expect(Person.with_deleted.find(person)).to eql(person)
    expect(Membership.with_deleted.find(membership)).to eql(membership)
  end

  scenario 'Editing a person' do
    visit person_path(create(:person, person_attributes))
    click_link 'Edit profile'
    fill_in 'Given name', with: 'Jane'
    fill_in 'Surname', with: 'Doe'
    click_button 'Update Person'

    within('.person-name') do
      expect(page).to have_text('Jane Doe')
    end
  end

  scenario 'Editing an invalid person' do
    visit person_path(create(:person, person_attributes))
    click_link 'Edit profile'
    fill_in 'Surname', with: ''
    click_button 'Update Person'

    expect(page).to have_text('Please review the problems')
    within('div.person_surname') do
      expect(page).to have_text('can\'t be blank')
    end
  end

  scenario 'Adding a profile image' do
    visit new_person_path
    fill_in 'Surname', with: person_attributes[:surname]
    attach_file 'Image',File.join(Rails.root, "spec", "fixtures", "placeholder.png")
    click_button 'Create Person'

    person = Person.find_by_surname(person_attributes[:surname])
    visit person_path(person)
    expect(page).to have_css("img[src*='#{person.image}']")
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
