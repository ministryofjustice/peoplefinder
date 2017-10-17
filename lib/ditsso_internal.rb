module OmniAuth
  module Strategies
    class DitssoInternal < OmniAuth::Strategies::OAuth2
      option :name, 'ditsso_internal'

      SSO_PROVIDER = ENV['DITSSO_INTERNAL_PROVIDER']

      option :client_options,
        site:          SSO_PROVIDER,
        authorize_url: "#{SSO_PROVIDER}/o/authorize/",
        token_url: "#{SSO_PROVIDER}/o/token/"

      uid do
        raw_info['id']
      end

      info do
        {
          first_name: raw_info['first_name'],
          last_name: raw_info['last_name'],
          email: raw_info['email'].downcase
        }
      end

      extra do
        {
          raw_info: raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/v1/user/me/').parsed
      end

      def callback_url
        ENV['DITSSO_CALLBACK_URL']
      end
    end
  end
end
