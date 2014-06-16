require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_apps#, domain: 'digital.justice.gov.uk'
end

# Monkey patch to strategy to allow us to add a select box instead of a text field
module OmniAuth
  module Strategies
    class GoogleApps
      def get_identifier
        f = OmniAuth::Form.new(:title => 'Google Apps Authentication')
        f.label_field('Google Apps Domain', 'domain')
        f.html("\n<select id='domain' name='domain'>")
        ['digital.justice.gov.uk', 'digital.cabinet-office.gov.uk'].each do |domain|
          f.html("\n  <option value='#{domain}'/>#{domain}</option>")
        end
        f.html("\n</select>")
        f.to_response
      end
    end
  end
end
