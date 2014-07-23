require 'rails_helper'

feature "Inviting a new user to the system" do

  let(:password) {generate(:password)}

  scenario 'System creates a user account and an invite email is sent to the user' do
    clear_emails
    user = create(:user)
    user.invite!

    open_email(user.email)

    expect(current_email).to have_text(user.name)
    expect(current_email).to have_text("You've been invited to the SCS Appraisal system")
    current_email.click_link('Complete your registration')

    expect(page).to have_text(user.name)
    expect(page).to have_text('Complete your registration')

    fill_in :user_password, with: password
    fill_in :user_password_confirmation, with: password

    click_button 'Finish'

    expect(page).to have_text('Registration is now complete')
  end


  scenario 'System creates a user account and a user inputs an incorrect password' do
    clear_emails
    user = create(:user)
    user.invite!
    open_email(user.email)

    expect(current_email).to have_text("You've been invited to the SCS Appraisal system")
    current_email.click_link('Complete your registration')

    fill_in :user_password, with: 'does not match'
    fill_in :user_password_confirmation, with: 'wibble wibble'
    click_button 'Finish'
    expect(page).to have_text("doesn't match Password")
  end

end