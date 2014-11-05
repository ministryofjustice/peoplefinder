require 'rails_helper'

RSpec.describe Peoplefinder::EmailAddress do
  let(:valid_login_domains) { ['something.gov.uk'] }

  subject { described_class.new(email, valid_login_domains) }

  describe '.valid_domain' do
    context 'with strings to match login domains' do
      let(:valid_login_domains) { ['dept.gov.uk'] }

      it "does not match a similar domain" do
        expect(described_class.new('me@dept-gov-uk.com', valid_login_domains)).not_to be_valid_domain
      end

      it "does not match a subdomain" do
        expect(described_class.new('me@sub.dept.gov.uk', valid_login_domains)).not_to be_valid_domain
      end

      it "only matches the whole domain" do
        expect(described_class.new('me@dept.gov.uk', valid_login_domains)).to be_valid_domain
      end

      it "does not match against the local part of the address" do
        expect(described_class.new('dept.gov.uk@dept.com', valid_login_domains)).not_to be_valid_domain
      end
    end

    context 'with regexp to match login domains' do
      let(:valid_login_domains) { [/depta?\.gov\.uk/] }

      it "does not match a similar domain" do
        expect(described_class.new('me@dept-gov.uk.com', valid_login_domains)).not_to be_valid_domain
      end

      it "matches a subdomain" do
        expect(described_class.new('me@dept.gov.uk', valid_login_domains)).to be_valid_domain
      end

      it "does not match against the local part of the address" do
        expect(described_class.new('depta.gov.uk@dept-gov-uk.com', valid_login_domains)).not_to be_valid_domain
      end
    end
  end

  describe '.valid_format' do
    context 'is badly formatted' do
      let(:email) { 'me-at-example.co.uk' }
      it { is_expected.not_to be_valid_format }
    end

    context 'is correctly formatted' do
      let(:email) { 'me@example.co.uk' }
      it { is_expected.to be_valid_format }
    end
  end

  describe '.valid_address' do
    it 'is nil' do
      expect(described_class.new(nil, valid_login_domains)).not_to be_valid_address
    end

    it 'is an empty string' do
      expect(described_class.new('', valid_login_domains)).not_to be_valid_address
    end

    it 'is badly formatted' do
      expect(described_class.new('me-at-example.co.uk', valid_login_domains)).not_to be_valid_address
    end

    it 'is from an invalid domain' do
      expect(described_class.new('me-at-example.co.uk', valid_login_domains)).not_to be_valid_address
    end

    it 'does not break the mail gem address_list initialiser' do
      expect(described_class.new('me@', valid_login_domains)).not_to be_valid_address
    end

    it 'is valid' do
      expect(described_class.new("me@something.gov.uk", valid_login_domains)).to be_valid_address
    end
  end

  context 'name inferral' do
    let(:email_john_smith) { described_class.new('john.smith.1@example.com', valid_login_domains) }
    let(:email_smithy) { described_class.new('smithy@example.com', valid_login_domains) }
    let(:email_anne_marie) { described_class.new('anne-marie.boris-smythe@example.com', valid_login_domains) }

    describe '.inferred_given_name' do
      it 'returns john.smith' do
        expect(email_john_smith.inferred_first_name).to eql('John')
      end

      it 'returns nil' do
        expect(email_smithy.inferred_first_name).to be_nil
      end

      it 'returns Anne-Marie' do
        expect(email_anne_marie.inferred_first_name).to eql('Anne-Marie')
      end
    end

    describe '.inferred_last_name' do
      it 'returns smith' do
        expect(email_john_smith.inferred_last_name).to eql('Smith')
      end

      it 'returns smithy' do
        expect(email_smithy.inferred_last_name).to eql('Smithy')
      end

      it 'returns Boris-Smythe' do
        expect(email_anne_marie.inferred_last_name).to eql('Boris-Smythe')
      end
    end
  end
end
