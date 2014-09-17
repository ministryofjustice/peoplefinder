module SpecSupport
  module Login
    def mock_logged_in_user
      controller.session[:current_user] =
        User.new('test.user@digital.moj.gov.uk')
    end

    def omni_auth_log_in_as(email)
      OmniAuth.config.test_mode = true

      OmniAuth.config.mock_auth[:gplus] = OmniAuth::AuthHash.new(
        provider: 'gplus',
        info: {
          email: email,
          first_name: 'John',
          last_name: 'Doe',
          name: 'John Doe'
        }
      )

      visit 'auth/gplus'
    end

    def token_log_in_as(email)
      token = create(:token, user_email: email)
      visit token_path(token)
    end

    def javascript_log_in
      visit '/'
      click_link 'log in'
    end
  end
end
