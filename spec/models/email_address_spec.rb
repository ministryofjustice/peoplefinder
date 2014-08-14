require 'rails_helper'

RSpec.describe EmailAddress do
  describe '.valid_domain' do
    context 'when it is not in the list of valid_login_domains' do
      it 'is not valid' do
        expect(described_class.new('me@something.else.com')).not_to be_valid_domain
      end
    end

    context 'when it is in the list of valid_login_domains' do
      it 'is valid' do
        expect(described_class.new("me@#{ Rails.configuration.valid_login_domains.first }")).to be_valid_domain
      end
    end
  end
end
