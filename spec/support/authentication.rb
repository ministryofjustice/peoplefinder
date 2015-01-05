module SpecSupport
  module Authentication
    def authenticate_as(user)
      session[:user_id] = user.id
    end

    def access_is_denied
      expect(page).to have_text('You have to be logged in')
    end

    def log_in_as(user)
      password = generate(:password)
      identity = create(:identity, password: password, user: user)

      visit new_login_path

      fill_in 'Username', with: identity.username
      fill_in 'Password', with: password
      click_button 'Log in'
    end
  end
end
