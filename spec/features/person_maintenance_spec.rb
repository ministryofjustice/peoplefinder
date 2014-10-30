require 'rails_helper'

feature 'Person maintenance' do
  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Creating a person with a complete profile', js: true do
    create(:group, name: 'Digital')

    javascript_log_in
    visit new_person_path
    expect(page).to have_title("New profile - #{ app_title }")
    fill_in_complete_profile_details

    click_button 'Create'
    check_creation_of_profile_details
  end

  scenario 'Creating an invalid person' do
    visit new_person_path
    click_button 'Create'
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
    fill_in_complete_profile_details

    click_button 'Create'

    expect(page).to have_text('1 result found')
    click_button 'Continue'
    check_creation_of_profile_details
    expect(Peoplefinder::Person.where(surname: person_attributes[:surname]).count).to eql(2)
  end

  scenario 'Cancelling creation of a person with an identical name' do
    create(:person, given_name: person_attributes[:given_name],
                    surname: person_attributes[:surname])
    visit new_person_path

    fill_in 'First name', with: person_attributes[:given_name]
    fill_in 'Surname', with: person_attributes[:surname]
    click_button 'Create'

    click_link 'Return to home page'
    expect(Peoplefinder::Person.where(surname: person_attributes[:surname]).count).to eql(1)
  end

  scenario 'Editing a person and giving them a name that already exists' do
    create(:person, given_name: person_attributes[:given_name],
                    surname: person_attributes[:surname])
    person = create(:person, given_name: 'Bobbie', surname: 'Browne')
    visit edit_person_path(person)

    fill_in 'First name', with: person_attributes[:given_name]
    fill_in 'Surname', with: person_attributes[:surname]
    click_button 'Update'

    expect(page).to have_title("Duplicate names found - #{ app_title }")
    click_button 'Continue'
    expect(Peoplefinder::Person.where(surname: person_attributes[:surname]).count).to eql(2)
  end

  scenario 'Deleting a person' do
    person = create(:person)
    visit edit_person_path(person)
    click_link('Delete this profile')
    expect { Peoplefinder::Person.find(person) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario 'Allow deletion of a person even when there are memberships' do
    membership = create(:membership)
    person = membership.person
    visit edit_person_path(person)
    click_link('Delete this profile')
    expect { Peoplefinder::Membership.find(membership) }.to raise_error(ActiveRecord::RecordNotFound)
    expect { Peoplefinder::Person.find(person) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario 'Editing a person' do
    visit person_path(create(:person, person_attributes))
    click_link 'Edit this profile'

    expect(page).to have_title("Edit profile - #{ app_title }")
    fill_in 'First name', with: 'Jane'
    fill_in 'Surname', with: 'Doe'
    click_button 'Update'

    expect(page).to have_content('Updated Jane Doe’s profile')
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

    person = Peoplefinder::Person.find_by_surname(person_attributes[:surname])
    visit person_path(person)
    expect(page).to have_css("img[src*='#{person.image.medium}']")
    expect(page).to have_css("img[alt*='Current photo of #{ person }']")

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

      expect(page).to have_title("Request profile update - #{ app_title }")
      within('h1') do
        expect(page).to have_text('Request profile update')
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

  scenario 'Toggling the phone number fields', js: true do
    create(:group, name: 'Digital')
    person = create(:person)
    javascript_log_in

    visit edit_person_path(person)

    check('No phone number')
    expect(page).not_to have_field('person_primary_phone_number')
    expect(page).not_to have_field('person_secondary_phone_number')

    uncheck('No phone number')
    fill_in('person_primary_phone_number', with: 'my-primary-phone')
    fill_in('person_secondary_phone_number', with: 'my-secondary-phone')

    check('No phone number')
    click_button 'Update'
    expect(Peoplefinder::Person.last.primary_phone_number).to be_blank
    expect(Peoplefinder::Person.last.secondary_phone_number).to be_blank

    visit edit_person_path(person)
    expect(page).not_to have_field('person_primary_phone_number')
    expect(page).not_to have_field('person_secondary_phone_number')
  end

  scenario 'Reporting a profile' do
    group = create(:group)
    person = create(:person)
    person.groups << group

    visit person_path(person)
    click_link 'Report this profile'

    expect(page).to have_title("Report this profile - #{ app_title }")
    select 'Duplicate profile', from: 'Reason for reporting'
    fill_in 'Additional details (optional)', with: 'Some stuff'
    expect { click_button 'Submit' }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(last_email.to).to include(group.team_email_address)
    expect(last_email.subject).to eql('A People Finder profile has been reported')
    expect(last_email.body.encoded).to have_text('Reason for reporting: Duplicate profile')
    expect(last_email.body.encoded).to have_text('Additional details: Some stuff')
    expect(last_email.body.encoded).to have_text(person_url(person))
  end

  scenario 'Adding skills and expertise to a new profile' do
    visit new_person_path
    fill_in 'Surname', with: 'Smith'
    fill_in 'person_tags', with: 'ruby,cakes and bakes'
    click_button 'Create'

    expect(page).to have_text('Skills and expertise')
    within '.tags' do
      expect(page).to have_text('Cakes and bakes')
      expect(page).to have_text('Ruby')
    end
  end

  scenario 'Editing skills and expertise with javascript', js: true do
    create(:group, name: 'Digital')
    person = create(:person, tags: 'Cooking')
    javascript_log_in

    visit edit_person_path(person)

    within('.select2-container') do
      expect(page).to have_text('Cooking')
    end

    # remove Cooking
    find('.select2-search-choice-close').click

    # add Baking
    page.execute_script("i = $('.select2-container input').first();")
    page.execute_script("i.val('baking').trigger('keydown');")
    find('.select2-results li:first-child').click

    # add Washing dishes
    page.execute_script("i.val('washing dishes').trigger('keydown');")
    find('.select2-results li:first-child').click

    click_button 'Update'
    within '.tags' do
      expect(page).not_to have_text('Cooking')
      expect(page).to have_text('Baking')
      expect(page).to have_text('Washing dishes')
    end
  end

  scenario 'Tagging is disabled' do
    without_feature("profile_tags") do
      visit new_person_path
      expect(page).not_to have_field('person_tags')
    end
  end
end
