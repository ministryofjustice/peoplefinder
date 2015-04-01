require 'rails_helper'

feature 'Upload CSV' do
  include PermittedDomainHelper

  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'uploading a good CSV file' do
    group = create(:group)

    visit new_admin_person_upload_path

    expect {
      attach_file 'File', File.expand_path('../../fixtures/valid.csv', __FILE__)
      select group.name, from: 'Team'
      click_button 'Upload'
    }.to change(Person, :count).by(2)

    expect(current_path).to eql(new_admin_person_upload_path)

    expect(page).to have_text('Successfully uploaded 2 people')
  end

  scenario 'uploading a bad CSV file' do
    group = create(:group)

    visit new_admin_person_upload_path

    expect {
      attach_file 'File', File.expand_path('../../fixtures/invalid.csv', __FILE__)
      select group.name, from: 'Team'
      click_button 'Upload'
    }.not_to change(Person, :count)

    expect(current_path).to eql(admin_person_uploads_path)

    expect(page).to have_text('Upload failed')
  end
end
