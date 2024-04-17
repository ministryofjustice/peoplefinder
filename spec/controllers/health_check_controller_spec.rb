require "rails_helper"

RSpec.describe HealthCheckController, type: :controller do
  describe "#index" do
    let(:passing) { double(available?: true, accessible?: true, errors: nil) } # rubocop:disable RSpec/VerifiedDoubles
    let(:failing) { double(available?: false, accessible?: false, errors: "error reason") } # rubocop:disable RSpec/VerifiedDoubles

    context "when a problem exists" do
      before do
        allow(HealthCheck::Database).to receive(:new).and_return(failing)
        allow(HealthCheck::OpenSearch).to receive(:new).and_return(failing)

        get :index
      end

      it "returns status bad gateway" do
        expect(response.status).to eq(500)
      end

      it "returns the expected response report" do
        expect(response.body).to eq({ checks: { database: false,
                                                search: false } }.to_json)
      end

      it "sends report to Sentry" do
        expect(Sentry).to receive(:capture_message).with(String)
        get :index
      end
    end

    context "when everything is ok" do
      before do
        allow(HealthCheck::Database).to receive(:new).and_return(passing)
        allow(HealthCheck::OpenSearch).to receive(:new).and_return(passing)

        get :index
      end

      it "returns HTTP success" do
        expect(response.status).to eq(200)
      end

      it "returns the expected response report" do
        expect(response.body).to eq({ checks: { database: true,
                                                search: true } }.to_json)
      end
    end
  end
end
