module Api
  class ApplicationController < ActionController::Base
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate_api_token
    protect_from_forgery with: :exception

    private

    def authenticate_api_token
      authenticate_or_request_with_http_token do |token, _options|
        ActiveSupport::SecurityUtils.secure_compare(
          ::Digest::SHA256.hexdigest(token),
          ::Digest::SHA256.hexdigest(ENV['PROFILE_API_TOKEN'])
        )
      end
    end
  end
end
