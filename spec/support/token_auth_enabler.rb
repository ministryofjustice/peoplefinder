# Token authentication is disabled by default.
# Here we enable it for the tests that have
# been built around token authentication
module TokenAuthEnabler
  extend ActiveSupport::Concern

  included do
    before do
      ENV['ENABLE_TOKEN_AUTH'] = 'YES PLEASE!'
    end
  end
end
