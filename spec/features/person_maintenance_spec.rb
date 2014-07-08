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
    uncheck('Monday')
    uncheck('Friday')
    click_button "Create Person"

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
  end

  scenario 'Creating a person and making them the leader of a group' do
    group = create(:group, name: 'Digital Justice')
    visit new_person_path
    fill_in 'Surname', with: person_attributes[:surname]
    fill_in 'Title', with: 'Head Honcho'
    select('Digital Justice', from: 'Group')
    check('Leader')
    click_button "Create Person"

    membership = Person.last.memberships.last
    expect(membership.role).to eql('Head Honcho')
    expect(membership.group).to eql(group)
    expect(membership.leader?).to be true
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

    expect(page).to have_content("Deleted #{person}’s profile")

    expect { Person.find(person) }.to raise_error(ActiveRecord::RecordNotFound)
    expect { Membership.find(membership) }.to raise_error(ActiveRecord::RecordNotFound)

    expect(Person.with_deleted.find(person)).to eql(person)
    expect(Membership.with_deleted.find(membership)).to eql(membership)
  end

  scenario 'Editing a person' do
    visit person_path(create(:person, person_attributes))
    click_link 'Edit this page'
    fill_in 'Given name', with: 'Jane'
    fill_in 'Surname', with: 'Doe'
    click_button 'Update Person'

    expect(page).to have_content("Updated Jane Doe’s profile")

    within('h1') do
      expect(page).to have_text('Jane Doe')
    end
  end

  scenario 'Removing a group' do
     group = create(:group, name: 'Digital Justice')
     person = create(:person, person_attributes)
     person.memberships.create(group: group)

     visit edit_person_path(person)
     click_link('remove')

     expect(page).to have_content("Removed Marco Polo from Digital Justice")
     expect(person.reload.memberships).to be_empty
     expect(current_path).to eql(edit_person_path(person))
  end


  scenario 'Editing an invalid person' do
    visit person_path(create(:person, person_attributes))
    click_link 'Edit this page'
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
    attach_file 'person[image]', sample_image
    click_button 'Create Person'

    person = Person.find_by_surname(person_attributes[:surname])
    visit person_path(person)
    expect(page).to have_css("img[src*='#{person.image.medium}']")
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
