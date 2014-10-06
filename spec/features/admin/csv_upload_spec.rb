require 'rails_helper'

feature 'CSV upload' do

  let(:password) { generate(:password) }
  let(:user) { create(:admin_user, name: 'Bob') }
  let(:identity) { create(:identity, password: password, user: user) }

  scenario 'Uploading a CSV' do
    visit admin_path
    log_in identity.username, password

    expect {
      attach_file 'File', Rails.root.join('spec', 'data', 'users.csv')
      click_button 'Upload'
    }.to change(User, :count).by(3)
    expect(current_path).to eql(admin_path)
    expect(page).to have_text('Users uploaded successfully')
  end

  scenario 'Uploading an empty file' do
    visit admin_path
    log_in identity.username, password

    click_button 'Upload'

    expect(current_path).to eql(admin_path)
    expect(page).to have_text('No users were uploaded')
  end
end
