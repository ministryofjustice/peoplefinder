require "rails_helper"

describe HealthCheck::Elasticsearch do
  subject { described_class.new }

  describe "#available?" do
    it "returns true if Elasticsearch responds to ping" do
      expect(subject).to be_available
    end

    it "returns false if Elasticsearch does not respond to ping" do
      allow(Elasticsearch::Model.client).to receive(:ping).and_return(false)
      expect(subject).not_to be_available
    end
  end

  describe "#accessible?" do
    it "returns true if Elasticsearch cluster health is green" do
      allow(subject).to receive(:cluster_status?).and_return(true)
      expect(subject).to be_accessible
    end

    it "returns false if Elasticsearch cluster health is yellow" do
      allow(subject).to receive(:cluster_status?).and_return(false)
      expect(subject).not_to be_accessible
    end

    it "returns false if Elasticsearch cluster health is red" do
      allow(subject).to receive(:cluster_status?).and_return(false)
      expect(subject).not_to be_accessible
    end
  end

  describe "#errors" do
    it "returns the exception messages if there is an error accessing the database" do
      allow(Elasticsearch::Model.client).to receive(:ping).and_return(false)
      subject.available?

      expect(subject.errors.first)
        .to match(/Elasticsearch Error: Could not connect to port \d+ on \S+ via \w+/)
    end

    it "returns an error an backtrace for errors not specific to a component" do
      allow(Elasticsearch::Model.client).to receive(:ping).and_raise(StandardError)
      subject.available?

      expect(subject.errors.first).to match(/Error: StandardError\nDetails/)
    end
  end
end
