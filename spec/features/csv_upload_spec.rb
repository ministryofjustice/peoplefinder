require 'rails_helper'

feature 'Upload CSV' do
  include ActiveJobHelper
  include PermittedDomainHelper

  let!(:group) { create(:group) }
  let(:email) { 'test.user@digital.justice.gov.uk' }

  before do
    create(:person, email: email, super_admin: true)
    omni_auth_log_in_as email
    visit new_admin_person_upload_path
    select group.name, from: 'Choose your team'
  end

  scenario 'only super admins can access uploader' do
    Person.find_by(email: email).update(super_admin: false)
    visit new_admin_person_upload_path
    expect(current_path).to eql home_path
    expect(page).to have_selector('.flash-message.warning', text: 'Unauthorised')
  end

  scenario 'uploading a good CSV file' do
    expect do
      attach_file 'Upload CSV file', File.expand_path('../../fixtures/valid.csv', __FILE__)
      click_button 'Upload'
    end.to change(Person, :count).by(2)

    expect(current_path).to eql(new_admin_person_upload_path)
    expect(page).to have_text('Successfully uploaded 2 people')

    %w(
      peter.bly@digital.justice.gov.uk
      jon.o.carey@digital.justice.gov.uk
    ).each do |email|
      person = Person.find_by(email: email)
      expect(person.groups).to eq([group])
      check_queued_notification(person)

    end
  end

  scenario 'uploading a good CSV file with optionals' do
    expect do
      attach_file 'Upload CSV file', File.expand_path('../../fixtures/valid_with_optionals.csv', __FILE__)
      click_button 'Upload'
    end.to change(Person, :count).by(2)

    expect(current_path).to eql(new_admin_person_upload_path)
    expect(page).to have_text('Successfully uploaded 2 people')

    %w(
      tom.o.carey@digital.justice.gov.uk
      tom.mason-buggs@digital.justice.gov.uk
    ).each do |email|
      person = Person.find_by(email: email)
      expect(person.groups).to eq([group])
      expect(person.location).to eq "Room 5.02, 5th Floor, Blue Core, 102, Petty France, London"
      check_queued_notification(person)
    end
  end

  scenario 'uploading a CSV file with bad records' do
    expect do
      attach_file 'Upload CSV file', File.expand_path('../../fixtures/invalid_rows.csv', __FILE__)
      click_button 'Upload'
    end.not_to change(Person, :count)

    expect(current_path).to eql(admin_person_uploads_path)

    expect(page).to have_text('Upload failed')
    expect(page).to have_text('can’t be used to access')
  end

  scenario 'uploading a bad CSV file with optionals' do
    expect do
      attach_file 'Upload CSV file', File.expand_path('../../fixtures/invalid_rows_with_optionals.csv', __FILE__)
      click_button 'Upload'
    end.not_to change(Person, :count)

    expect(current_path).to eql(admin_person_uploads_path)
    expect(page).to have_text('Upload failed')
    expect(page).to have_text('can’t be used to access')
  end

  scenario 'forgetting to attach a file' do
    click_button 'Upload'
    expect(page).to have_text('Upload failed')
    expect(page).to have_text('Upload CSV file is required')
  end

  def check_new_user_notification_email(addr)
    msg = ActionMailer::Base.deliveries.reverse.find { |d| d.to.include?(addr) }
    expect(msg).not_to be_nil

    expect(msg.subject).to eq('You’re on MOJ People Finder, check your profile today')
  end

  def check_queued_notification(person)
    expect(QueuedNotification.where(person_id: person.id)).not_to be_empty
  end
end
