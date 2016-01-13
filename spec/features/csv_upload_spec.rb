require 'rails_helper'

feature 'Upload CSV' do
  include ActiveJobHelper
  include PermittedDomainHelper

  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'uploading a good CSV file' do
    group = create(:group)

    visit new_admin_person_upload_path

    expect do
      attach_file 'Upload CSV file', File.expand_path('../../fixtures/valid.csv', __FILE__)
      select group.name, from: 'Choose your team'
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
      check_new_user_notification_email(email)
    end
  end

  scenario 'uploading a bad CSV file' do
    group = create(:group)

    visit new_admin_person_upload_path

    expect do
      attach_file 'Upload CSV file', File.expand_path('../../fixtures/invalid.csv', __FILE__)
      select group.name, from: 'Choose your team'
      click_button 'Upload'
    end.not_to change(Person, :count)

    expect(current_path).to eql(admin_person_uploads_path)

    expect(page).to have_text('Upload failed')
    expect(page).to have_text('can’t be used to access')
  end

  scenario 'forgetting to attach a file' do
    group = create(:group)

    visit new_admin_person_upload_path
    select group.name, from: 'Choose your team'
    click_button 'Upload'

    expect(page).to have_text('Upload failed')
    expect(page).to have_text('Upload CSV file is required')
  end

  def check_new_user_notification_email(addr)
    msg = ActionMailer::Base.deliveries.reverse.find { |d| d.to.include?(addr) }
    expect(msg).not_to be_nil

    expect(msg.subject).to eq('You’re on MOJ People Finder, check your profile today')
  end
end
