require 'rails_helper'

feature 'Administration password reset' do
  let(:password) { generate(:password) }
  let(:new_password) { generate(:password) }
  let(:not_the_new_password) { generate(:password) }

  let(:identity) { create(:identity, password: password) }
  let(:user) { create(:admin_user, name: 'Bob', identities: [identity]) }
  let(:non_existant_email) { 'hello@example.com' }
  let(:invalid_token) { "AnInvalidToken" }

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

    expect(current_path).to eq edit_admin_password_reset_path

    fill_in 'Password', with: new_password
    fill_in 'Password confirmation', with: new_password
    click_button 'Reset password'

    visit new_login_path
    fill_in 'Username', with: identity.username
    fill_in 'Password', with: new_password
    click_button 'Log in'

    expect(current_path).to eql(admin_path)
    expect(page).to have_text("Logged in as #{user.name}")
  end

  scenario 'with non-existant email' do
    visit admin_path
    click_link 'Forgot password'

    expect(current_path).to eq(new_admin_password_reset_path)

    fill_in 'Email', with: non_existant_email
    click_button 'Send password reset link'

    expect(page).to have_text 'No admin user with that email exists'
  end

  scenario 'viewing form with expired token' do
    visit admin_path
    click_link 'Forgot password'

    expect(current_path).to eq(new_admin_password_reset_path)

    fill_in 'Email', with: user.email
    click_button 'Send password reset link'

    expect(current_path).to eql new_login_path
    expect(page).to have_text('Password reset link sent')

    expect(last_email.body.raw_source).to include 'Please click on the link below to reset your password:'

    Timecop.travel 4.hours.from_now

    visit(links_in_email(last_email).first)

    expect(current_path).to eq new_admin_password_reset_path
    expect(page).to have_content 'Your password reset token has expired'
  end

  scenario 'submit form with expired token' do
    visit admin_path
    click_link 'Forgot password'

    expect(current_path).to eq(new_admin_password_reset_path)

    fill_in 'Email', with: user.email
    click_button 'Send password reset link'

    expect(current_path).to eql new_login_path
    expect(page).to have_text('Password reset link sent')

    expect(last_email.body.raw_source).to include 'Please click on the link below to reset your password:'

    visit(links_in_email(last_email).first)

    expect(current_path).to eq edit_admin_password_reset_path

    fill_in 'Password', with: new_password
    fill_in 'Password confirmation', with: new_password

    Timecop.travel 4.hours.from_now

    click_button 'Reset password'

    expect(current_path).to eq new_admin_password_reset_path
    expect(page).to have_content 'Your password reset token has expired'
  end

  scenario 'with invalid token' do
    visit edit_admin_password_reset_path(token: invalid_token)
    expect(current_path).to eq new_admin_password_reset_path
    expect(page).to have_content 'Your password reset token has expired'
  end

  scenario 'with mismatched passwords' do
    visit admin_path
    click_link 'Forgot password'

    expect(current_path).to eq(new_admin_password_reset_path)

    fill_in 'Email', with: user.email
    click_button 'Send password reset link'

    expect(current_path).to eql new_login_path
    expect(page).to have_text('Password reset link sent')

    expect(last_email.body.raw_source).to include 'Please click on the link below to reset your password:'

    visit(links_in_email(last_email).first)

    expect(current_path).to eq edit_admin_password_reset_path

    fill_in 'Password', with: new_password
    fill_in 'Password confirmation', with: not_the_new_password
    click_button 'Reset password'

    expect(page).to have_content "doesn't match"
  end
end
