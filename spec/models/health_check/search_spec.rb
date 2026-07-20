require "rails_helper"

describe HealthCheck::Search do
  subject(:search) { described_class.new }

  describe "#available?" do
    it "returns true when the pg_trgm extension is enabled" do
      allow(Person.connection).to receive(:extension_enabled?).with("pg_trgm").and_return(true)
      expect(search).to be_available
    end

    it "returns false when the pg_trgm extension is not enabled" do
      allow(Person.connection).to receive(:extension_enabled?).with("pg_trgm").and_return(false)
      expect(search).not_to be_available
    end

    it "returns false and records an error when a StandardError is raised" do
      allow(Person.connection).to receive(:extension_enabled?).and_raise(StandardError, "connection lost")
      expect(search).not_to be_available
      expect(search.errors.first).to match(/Error: connection lost\nDetails/)
    end
  end

  describe "#accessible?" do
    it "always returns true" do
      expect(search).to be_accessible
    end
  end
end
