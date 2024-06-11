module SpecSupport
  module Login
    def mock_readonly_user
      allow(ReadonlyUser).to receive(:from_request).and_return ReadonlyUser.new
    end

    def mock_logged_in_user(super_admin: false)
      controller.session[::Login::TYPE_KEY] = "person"
      controller.session[::Login::SESSION_KEY] =
        create(:person, email: "test.user@digital.justice.gov.uk", super_admin:).id
    end

    def mock_logged_in_external_user
      controller.session[::Login::TYPE_KEY] = "external_user"
      controller.session[::Login::SESSION_KEY] = create(:external_user, email: "test.user@gov.sscl.com").id
    end

    def current_user
      Person.where(email: "test.user@digital.justice.gov.uk").first
    end

    def token_log_in_as(email)
      token = create(:token, user_email: email)
      visit token_path(token)
    end
  end
end
