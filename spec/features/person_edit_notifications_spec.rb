require 'rails_helper'

feature 'Person edit notifications' do
  include ActiveJobHelper
  include PermittedDomainHelper

  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }
  before do
    omni_auth_log_in_as(person.email)
  end

  scenario 'Creating a person with different email' do
    visit new_person_path

    fill_in 'First name', with: 'Bob'
    fill_in 'Last name', with: 'Smith'
    fill_in 'Main email', with: 'bob.smith@digital.justice.gov.uk'
    expect do
      click_button 'Save', match: :first
    end.to change { QueuedNotification.count }.by(1)

    notification = QueuedNotification.last
    expect(notification.current_user_id).to eq person.id
    expect(notification.sent).to be false
    expect(notification.edit_finalised).to be true
    expect(notification.changes_hash['data']['raw']).to eq(
      'given_name' => [nil, 'Bob'],
      'surname' => [nil, 'Smith'],
      'location_in_building' => [nil, ''],
      'building' => [nil, ''],
      'city' => [nil, ''],
      'primary_phone_number' => [nil, ''],
      'secondary_phone_number' => [nil, ''],
      'pager_number' => [nil, ''],
      'email' => [nil, 'bob.smith@digital.justice.gov.uk'],
      'secondary_email' => [nil, ''],
      'description' => [nil, ''],
      'current_project' => [nil, ''],
      'slug' => [nil, 'bob-smith']
    )
  end

  scenario 'Deleting a person with different email' do
    person = create(:person, email: 'bob.smith@digital.justice.gov.uk')
    visit person_path(person)
    expect { click_delete_profile }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(last_email.subject).to eq('Your profile on MOJ People Finder has been deleted')
    check_email_to_and_from
  end

  scenario 'Editing a person with different email' do
    digital = create(:group, name: 'Digital')
    person = create(:person, :member_of, team: digital, given_name: 'Bob', surname: 'Smith', email: 'bob.smith@digital.justice.gov.uk')
    visit person_path(person)
    click_edit_profile
    fill_in 'Last name', with: 'Smelly Pants'
    expect do
      click_button 'Save', match: :first
    end.to change { QueuedNotification.count }.by(1)
    expect(QueuedNotification.last.changes_hash['data']['raw']['surname']).to eq(["Smith", "Smelly Pants"])
  end

  scenario 'Editing a person with same email' do
    visit person_path(person)
    click_edit_profile
    fill_in 'Last name', with: 'Smelly Pants'
    expect do
      click_button 'Save', match: :first
    end.not_to change { ActionMailer::Base.deliveries.count }
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
