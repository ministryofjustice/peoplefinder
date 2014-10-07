require 'rails_helper'

feature 'CSV upload' do

  let(:user) { create(:admin_user, name: 'Bob') }

  before do
    log_in_as user
  end

  scenario 'Uploading a CSV' do
    visit admin_path

    expect {
      attach_file 'File', Rails.root.join('spec', 'data', 'users.csv')
      click_button 'Upload'
    }.to change(User, :count).by(3)
    expect(current_path).to eql(admin_path)
    expect(page).to have_text('Users uploaded successfully')
  end

  scenario 'Uploading an empty file' do
    visit admin_path

    click_button 'Upload'

    expect(current_path).to eql(admin_path)
    expect(page).to have_text('No users were uploaded')
  end
end
