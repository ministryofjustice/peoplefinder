module SpecSupport
  module Login
    def mock_logged_in_user
      controller.session[:current_user_id] = User.for_email("test.user@#{ Rails.configuration.valid_login_domains.first }").id
    end

    def current_test_user
      User.where(id: controller.session[:current_user_id]).first
    end

    def log_in_as(email, password)
      visit '/sessions/new'
      fill_in 'auth_key', with: email
      fill_in 'password', with: password
      click_button 'Login'
    end
  end
end
