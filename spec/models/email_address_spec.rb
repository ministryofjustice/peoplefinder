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

  describe '.valid_format' do
    it 'is badly formatted' do
      expect(described_class.new('me-at-example.co.uk')).not_to be_valid_format
    end

    it 'is valid' do
      expect(described_class.new('me@example.co.uk')).to be_valid_format
    end
  end

  describe '.valid_address' do
    it 'is nil' do
      expect(described_class.new(nil)).not_to be_valid_address
    end

    it 'is an empty string' do
      expect(described_class.new('')).not_to be_valid_address
    end

    it 'is badly formatted' do
      expect(described_class.new('me-at-example.co.uk')).not_to be_valid_address
    end

    it 'is from an invalid domain' do
      expect(described_class.new('me-at-example.co.uk')).not_to be_valid_address
    end

    it 'does not break the mail gem address_list initialiser' do
      expect(described_class.new('me@')).not_to be_valid_address
    end

    it 'is valid' do
      expect(described_class.new("me@#{ Rails.configuration.valid_login_domains.first }")).to be_valid_address
    end
  end

  context 'name inferral' do
    let(:email_john_smith) { described_class.new('john.smith.1@example.com') }
    let(:email_smithy) { described_class.new('smithy@example.com') }

    describe '.inferred_given_name' do
      it 'returns john.smith' do
        expect(email_john_smith.inferred_first_name).to eql('john')
      end

      it 'returns nil' do
        expect(email_smithy.inferred_first_name).to be_nil
      end
    end

    describe '.inferred_last_name' do
      it 'returns smith' do
        expect(email_john_smith.inferred_last_name).to eql('smith')
      end

      it 'returns smithy' do
        expect(email_smithy.inferred_last_name).to eql('smithy')
      end
    end
  end
end
