require "rails_helper"

RSpec.describe ReadonlyUser, type: :model do
  subject(:read_only_user) { described_class.new }

  let(:be_readonly_user) { be_instance_of described_class }

  describe ".from_request" do
    subject(:from_request) { described_class.from_request(request) }

    let(:request) { ActionDispatch::TestRequest.create }

    context "when client IP is whitelisted" do
      before do
        allow(request).to receive(:remote_ip_whitelisted?).and_return(true)
      end

      it "returns instance of #{described_class}" do
        expect(from_request).to be_readonly_user
      end
    end

    context "when client IP is not whitelisted" do
      before do
        allow(request).to receive(:remote_ip_whitelisted?).and_return(false)
      end

      it "returns nil" do
        expect(from_request).not_to be_readonly_user
        expect(from_request).to be_nil
      end
    end

    context "with whitelist" do
      let(:ip_whitelist) { "127.0.0.2/31;127.0.0.4/32" }

      before do
        allow(Rails.configuration).to receive(:readonly_ip_whitelist).and_return ip_whitelist
      end

      context "when IPs in CIDR range" do
        (2..4).each do |i|
          it "accepts IP 127.0.0.#{i}" do
            request.remote_addr = "127.0.0.#{i}"
            expect(from_request).to be_readonly_user
          end
        end
      end

      context "with IPs outside CIDR range" do
        [1, 5].each do |i|
          it "rejects IP 127.0.0.#{i}" do
            request.remote_addr = "127.0.0.#{i}"
            expect(from_request).to be_nil
          end
        end
      end
    end
  end

  describe "#id" do
    it "returns :readonly" do
      expect(read_only_user.id).to be :readonly
    end
  end

  describe "#super_admin?" do
    it "returns false" do
      expect(read_only_user).not_to be_super_admin
    end
  end
end
