require "rails_helper"

describe HealthCheck::Elasticsearch do
  subject(:elasticsearch) { described_class.new }

  describe "#available?" do
    it "returns true if Elasticsearch responds to ping" do
      expect(elasticsearch).to be_available
    end

    it "returns false if Elasticsearch does not respond to ping" do
      allow(Elasticsearch::Model.client).to receive(:ping).and_return(false)
      expect(elasticsearch).not_to be_available
    end
  end

  describe "#accessible?" do
    it "returns true if Elasticsearch cluster health is green" do
      allow(elasticsearch).to receive(:cluster_status?).and_return(true) # rubocop:disable RSpec/SubjectStub
      expect(elasticsearch).to be_accessible
    end

    it "returns false if Elasticsearch cluster health is not green" do
      allow(elasticsearch).to receive(:cluster_status?).and_return(false) # rubocop:disable RSpec/SubjectStub
      expect(elasticsearch).not_to be_accessible
    end
  end

  describe "#errors" do
    it "returns the exception messages if there is an error accessing the database" do
      allow(Elasticsearch::Model.client).to receive(:ping).and_return(false)
      elasticsearch.available?

      expect(elasticsearch.errors.first)
        .to match(/Elasticsearch Error: Could not connect to port \d+ on \S+ via \w+/)
    end

    it "returns an error an backtrace for errors not specific to a component" do
      allow(Elasticsearch::Model.client).to receive(:ping).and_raise(StandardError)
      elasticsearch.available?

      expect(elasticsearch.errors.first).to match(/Error: StandardError\nDetails/)
    end
  end
end
