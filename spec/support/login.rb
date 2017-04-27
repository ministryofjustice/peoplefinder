module SpecSupport
  module Login
    def mock_readonly_user
      allow(ReadonlyUser).to receive(:from_request).and_return ReadonlyUser.new
    end

    def mock_logged_in_user
      controller.session[::Login::SESSION_KEY] =
        create(:person, email: 'test.user@digital.justice.gov.uk').id
    end

    def current_user
      Person.where(email: 'test.user@digital.justice.gov.uk').first
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
      click_link 'Log in using Google+'
    end
  end
end
