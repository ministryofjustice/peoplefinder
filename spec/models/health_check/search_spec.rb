require "rails_helper"

describe HealthCheck::Search do
  subject(:search_check) { described_class.new }

  describe "#available?" do
    it "returns true when pg_trgm extension is enabled" do
      allow(Person.connection).to receive(:extension_enabled?).with("pg_trgm").and_return(true)
      expect(search_check).to be_available
    end

    it "returns false when pg_trgm extension is not enabled" do
      allow(Person.connection).to receive(:extension_enabled?).with("pg_trgm").and_return(false)
      expect(search_check).not_to be_available
    end

    it "returns false and logs error when an exception is raised" do
      allow(Person.connection).to receive(:extension_enabled?).and_raise(StandardError)
      expect(search_check).not_to be_available
      expect(search_check.errors).not_to be_empty
    end
  end

  describe "#accessible?" do
    it "returns true" do
      expect(search_check).to be_accessible
    end
  end
end
