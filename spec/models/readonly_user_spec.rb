require 'rails_helper'

RSpec.describe ReadonlyUser, type: :model do
  subject { described_class.new }

  describe '.from_request' do
    let(:request) { double('request') }

    subject { described_class.from_request(request) }

    # when request IP is whitelisted were return an instance of read-only user
    context 'when client IP is whitelisted' do
      before do
        expect(request).to receive(:remote_ip_whitelisted?).and_return(true)
      end

      it "returns instance of #{described_class}" do
        is_expected.to be_instance_of described_class
      end
    end

    context 'when client IP is not whitelisted' do
      before do
        expect(request).to receive(:remote_ip_whitelisted?).and_return(false)
      end

      it 'returns nil' do
        is_expected.to_not be_instance_of described_class
        is_expected.to be_nil
      end
    end
  end

  describe '#id' do
    it 'returns :readonly' do
      expect(subject.id).to be :readonly
    end
  end

  describe '#super_admin?' do
    it 'returns false' do
      expect(subject).not_to be_super_admin
    end
  end

end
