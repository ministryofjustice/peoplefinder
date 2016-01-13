require 'spec_helper'
require 'health_check/database_configuration'

describe HealthCheck::DatabaseConfiguration do
  subject { described_class.new(config_hash) }

  describe 'to_s' do
    context 'with all safe fields' do
      let(:config_hash) do
        {
          'adapter' => 'postgresql',
          'database' => 'foo_test',
          'host' => 'db.example.com',
          'port' => 1337
        }
      end

      it 'lists all fields in alphabetical order' do
        expect(subject.to_s).
          to eq('adapter=postgresql database=foo_test host=db.example.com port=1337')
      end
    end

    context 'with unsafe fields' do
      let(:config_hash) do
        {
          'adapter' => 'postgresql',
          'pool' => 5,
          'database' => 'foo_test',
          'host' => 'db.example.com',
          'port' => 1337,
          'username' => 'aoluser',
          'password' => 'SuperSecret'
        }
      end

      it 'excludes password' do
        expect(subject.to_s).not_to match(/password|SuperSecret/)
      end

      it 'excludes username' do
        expect(subject.to_s).not_to match(/username|aoluser/)
      end
    end

    context 'with a comprehensive url' do
      let(:config_hash) do
        {
          'adapter' => 'postgresql',
          'url' => 'postgresql://aoluser:SuperSecret@db.example.com:1337/foo_test'
        }
      end

      it 'preserves non-url parameters' do
        expect(subject.to_s).to match(/adapter=postgresql/)
      end

      it 'extracts database' do
        expect(subject.to_s).to match(/database=foo_test/)
      end

      it 'extracts host' do
        expect(subject.to_s).to match(/host=db\.example\.com/)
      end

      it 'extracts port' do
        expect(subject.to_s).to match(/port=1337/)
      end

      it 'excludes password' do
        expect(subject.to_s).not_to match(/SuperSecret/)
      end

      it 'excludes username' do
        expect(subject.to_s).not_to match(/aoluser/)
      end
    end

    context 'with a url without all fields' do
      let(:config_hash) do
        {
          'adapter' => 'postgresql',
          'url' => 'postgresql://localhost/foo_test'
        }
      end

      it 'excludes port' do
        expect(subject.to_s).not_to match(/port/)
      end
    end
  end
end
