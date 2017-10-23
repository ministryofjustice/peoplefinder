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
        # Here we are skipping the verification of the 'code' param
        # as it seems to be a requirement of the live sso provider.
        # This is based on the demo applicaion provided as:
        # https://github.com/uktrade/rails-abc-example/blob/master/lib/ditsso_internal.rb#L33
        access_token_path = "/api/v1/user/me/?access_token=#{access_token.token}"
        @raw_info ||= access_token.get(access_token_path).parsed
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
