class AuthUserLoader
  class << self
    def find_auth_email(email)
      auth_user_loader = new(email)
      auth_user_loader&.auth_email
    end
  end

  attr_reader :auth_email

  def initialize(email)
    @auth_email = from_api(email)
  end

  private

  include HTTParty

  BASE_URL = ENV['DITSSO_INTERNAL_PROVIDER'] || 'http://test.local'
  AUTH_TOKEN = ENV['DIT_ABC_TOKEN'] || 'abc'

  def from_api(email)
    response = HTTParty.get(
      "#{URI.join(BASE_URL, '/api/v1/user/introspect')}?email=#{email}",
      headers: {
        'Authorization' => "Bearer #{AUTH_TOKEN}"
      }
    )

    return nil unless response.success?
    JSON.parse(response.body)['email']
  end
end
