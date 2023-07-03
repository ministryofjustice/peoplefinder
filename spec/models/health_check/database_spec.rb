require "rails_helper"

describe HealthCheck::Database do
  subject(:database) { described_class.new }

  describe "#available?" do
    it "returns true if the database is available" do
      expect(database).to be_available
    end

    it "returns false if the database is not available" do
      allow(ActiveRecord::Base.connection).to receive(:active?).and_return(false)
      expect(database).not_to be_available
    end
  end

  describe "#accessible?" do
    it "returns true if the database is accessible with our credentials" do
      expect(database).to be_accessible
    end

    it "returns false if the database is not accessible with our credentials" do
      allow(subject).to receive(:execute_simple_select_on_database) # rubocop:disable RSpec/SubjectStub
        .and_raise(PG::ConnectionBad.new("Database has gone away"))
      result = database.accessible?
      expect(result).to be false
    end
  end

  describe "#errors" do
    it "returns the exception messages if there is an error accessing the database" do
      allow(ActiveRecord::Base.connection).to receive(:active?).and_return(false)
      database.available?

      expect(database.errors.first).to match(/could not connect with .*?_test/)
    end

    it "returns an error an backtrace for errors not specific to a component" do
      allow(ActiveRecord::Base.connection).to receive(:active?).and_raise(StandardError)
      database.available?

      expect(database.errors.first).to match(/Error: StandardError\nDetails/)
    end
  end
end
