require 'rails_helper'

feature "Reset users password" do

  let(:forgetful_user) { create(:user) }
  let(:password) { generate(:password) }

  scenario "when a user requests for a password reset link" do
    visit '/'
    expect(page).to have_text('Please log in to continue')

    click_link 'Forgotten your password?'


    fill_in :email, with: forgetful_user.email
    click_button 'Submit'

    expect(page).to have_text( 'An email with a link to reset your password has been sent')

  end

  scenario "when a user clicks on the email link and sets a new password" do
    clear_emails
    visit new_passwords_path

    fill_in :email, with: forgetful_user.email
    click_button'Submit'

    expect(page).to have_text( 'An email with a link to reset your password has been sent')

    open_email(forgetful_user.email)

    current_email.click_link('Password reset link')

    expect(page).to have_text('Enter a new password')

    fill_in :user_password, with: password
    fill_in :user_password_confirmation, with: password

    click_button 'Submit'

    expect(page).to have_text('Your password has been updated')

    forgetful_user.reload
    expect(forgetful_user.authenticate(password)).to eql(forgetful_user)
  end

  scenario "when a user tries to set an invalid password" do
    clear_emails
    visit new_passwords_path

    fill_in :email, with: forgetful_user.email
    click_button'Submit'

    expect(page).to have_text( 'An email with a link to reset your password has been sent')

    open_email(forgetful_user.email)

    current_email.click_link('Password reset link')

    expect(page).to have_text('Enter a new password')

    fill_in :user_password, with: password
    fill_in :user_password_confirmation, with: 'this will not match'

    click_button 'Submit'

    expect(page).to have_text('Your password and password confirmation were invalid')
    expect(page).to have_text("doesn't match Password")

    expect(forgetful_user.authenticate(password)).to eql(false)
  end

  scenario "when a user isn't registered with the system, they should not be able to ask for a reset token" do
    visit new_passwords_path
    fill_in :email, with: 'basil.brush@example.com'
    click_button 'Submit'

    expect(page).to have_text("An account with that email address can’t be found")
  end

  scenario "when a person testing security uses a random reset token, it should not allow them to do this" do
    visit passwords_path(token: SecureRandom.urlsafe_base64)
    expect(page).to have_text("That doesn’t appear to be a valid token")
  end

end
