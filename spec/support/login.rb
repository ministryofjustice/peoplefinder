module SpecSupport
  module Login
    def mock_logged_in_user
      controller.session[:current_user] = User.new('test.user@digital.moj.gov.uk')
    end
  end
end
