module SpecSupport
  module Login
    def mock_logged_in_user
      controller.session[:current_user] = User.new('test.user@digital.moj.gov.uk')
    end

    def log_in_as(email)
      OmniAuth.config.test_mode = true

      OmniAuth.config.mock_auth[:google_apps] = OmniAuth::AuthHash.new({
        provider: 'google_apps',
        info: {
          email: email
        }
      })

      visit 'auth/google_apps'
    end
  end
end
