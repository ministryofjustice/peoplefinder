require "rails_helper"

describe HealthCheck::Database do
  subject(:database) { described_class.new }

  describe "#available?" do
    it "returns true if the database is available" do
      expect(database).to be_available
    end

    it "returns false if the database is not available" do
      allow(ActiveRecord::Base.connection).to receive(:execute).and_return(nil)
      expect(database).not_to be_available
    end
  end

  describe "#accessible?" do
    it "always returns true" do
      expect(database).to be_accessible
    end
  end

  describe "#errors" do
    it "returns an error an backtrace for errors not specific to a component" do
      allow(ActiveRecord::Base.connection).to receive(:execute).and_raise(StandardError)
      database.available?

      expect(database.errors.first).to match(/Error: StandardError\nDetails/)
    end
  end
end
