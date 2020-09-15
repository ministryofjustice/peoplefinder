require 'rails_helper'

RSpec.describe ReadonlyUser, type: :model do
  subject { described_class.new }

  let(:be_readonly_user) { be_instance_of described_class }

  describe '.from_request' do
    let(:request) { ActionDispatch::TestRequest.create }

    subject { described_class.from_request(request) }

    context 'when client IP is whitelisted' do
      before do
        expect(request).to receive(:remote_ip_whitelisted?).and_return(true)
      end

      it "returns instance of #{described_class}" do
        expect(subject).to be_readonly_user
      end
    end

    context 'when client IP is not whitelisted' do
      before do
        expect(request).to receive(:remote_ip_whitelisted?).and_return(false)
      end

      it 'returns nil' do
        expect(subject).to_not be_readonly_user
        expect(subject).to be_nil
      end
    end

    context 'with whitelist' do
      let(:ip_whitelist) { '127.0.0.2/31;127.0.0.4/32' }
      before do
        allow(Rails.configuration).to receive(:readonly_ip_whitelist).and_return ip_whitelist
      end

      context "when IPs in CIDR range" do
        (2..4).each do |i|
          it "accepts IP 127.0.0.#{i}" do
            request.remote_addr = "127.0.0.#{i}"
            expect(subject).to be_readonly_user
          end
        end
      end

      context "with IPs outside CIDR range" do
        [1, 5].each do |i|
          it "rejects IP 127.0.0.#{i}" do
            request.remote_addr = "127.0.0.#{i}"
            expect(subject).to be_nil
          end
        end
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
