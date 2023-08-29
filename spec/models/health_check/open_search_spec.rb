require "rails_helper"

describe HealthCheck::OpenSearch do
  subject(:opensearch) { described_class.new }

  describe "#available?" do
    it "returns true if OpenSearch responds to ping" do
      expect(opensearch).to be_available
    end

    it "returns false if OpenSearch does not respond to ping" do
      allow(OpenSearch::Model.client).to receive(:ping).and_return(false)
      expect(opensearch).not_to be_available
    end
  end

  describe "#accessible?" do
    it "returns true if OpenSearch cluster health is green" do
      allow(opensearch).to receive(:cluster_status?).and_return(true) # rubocop:disable RSpec/SubjectStub
      expect(opensearch).to be_accessible
    end

    it "returns false if OpenSearch cluster health is not green" do
      allow(opensearch).to receive(:cluster_status?).and_return(false) # rubocop:disable RSpec/SubjectStub
      expect(opensearch).not_to be_accessible
    end
  end

  describe "#errors" do
    it "returns the exception messages if there is an error accessing the database" do
      allow(OpenSearch::Model.client).to receive(:ping).and_return(false)
      opensearch.available?

      expect(opensearch.errors.first)
        .to match(/OpenSearch Error: Could not connect to port \d+ on \S+ via \w+/)
    end

    it "returns an error an backtrace for errors not specific to a component" do
      allow(OpenSearch::Model.client).to receive(:ping).and_raise(StandardError)
      opensearch.available?

      expect(opensearch.errors.first).to match(/Error: StandardError\nDetails/)
    end
  end
end
