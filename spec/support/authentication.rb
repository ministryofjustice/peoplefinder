module SpecSupport
  module Authentication
    def authenticate_as(user)
      session[:user_id] = user.id
    end

    def access_is_denied
      expect(page).to have_text('not authorised')
    end

    def log_in(username, password)
      fill_in 'Username', with: username
      fill_in 'Password', with: password
      click_button 'Log in'
    end
  end
end
