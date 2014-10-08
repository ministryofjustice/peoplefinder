require 'rails_helper'

feature 'Administration password reset' do
  let(:password) { generate(:password) }
  let(:identity) { create(:identity, password: password) }
  let(:user) { create(:admin_user, name: 'Bob', identities: [identity]) }

  scenario 'with valid credentials' do
    visit admin_path
    click_link 'Forgot password'

    expect(current_path).to eq(new_admin_password_reset_path)

    fill_in 'Email', with: user.email
    click_button 'Send password reset link'

    expect(current_path).to eql new_login_path
    expect(page).to have_text('Password reset link sent')

    expect(last_email.body.raw_source).to include 'Please click on the link below to reset your password:'

    visit(links_in_email(last_email).first)
  end
end
