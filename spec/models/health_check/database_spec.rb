require 'rails_helper'

describe HealthCheck::Database do
  subject { described_class.new }

  context '#available?' do
    it 'returns true if the database is available' do
      expect(subject).to be_available
    end

    it 'returns false if the database is not available' do
      allow(ActiveRecord::Base).to receive(:connected?).and_return(false)
      expect(subject).not_to be_available
    end
  end

  context '#accessible?' do
    it 'returns true if the database is accessible with our credentials' do
      expect(subject).to be_accessible
    end

    it 'returns false if the database is not accessible with our credentials' do
      allow(subject).to receive(:execute_simple_select_on_database).
        and_raise(PG::ConnectionBad.new('Database has gone away'))
      result = subject.accessible?
      expect(result).to be false
    end
  end

  context '#errors' do
    it 'returns the exception messages if there is an error accessing the database' do
      allow(ActiveRecord::Base).to receive(:connected?).and_return(false)
      subject.available?

      expect(subject.errors.first).to match(/could not connect to \S+_test/)
    end

    it 'returns an error an backtrace for errors not specific to a component' do
      allow(ActiveRecord::Base).to receive(:connected?).and_raise(StandardError)
      subject.available?

      expect(subject.errors.first).to match(/Error: StandardError\nDetails/)
    end
  end
end
