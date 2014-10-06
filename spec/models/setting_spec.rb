require 'rails_helper'

RSpec.describe Setting, type: :model do

  describe '[]=' do
    it 'stores the value in the database' do
      expect {
        described_class[:foo] = 'bar'
      }.to change(described_class, :count).by(1)
    end
  end

  describe '[]' do
    it 'retrieves the value from the database' do
      described_class.create!(key: 'foo', value: 'bar')
      expect(described_class[:foo]).to eql('bar')
    end

    it 'returns nil if the value does not exist' do
      expect(described_class[:unset]).to be_nil
    end
  end

  describe 'fetch' do
    it 'returns the set value' do
      described_class[:set] = 'OK'
      expect(described_class.fetch(:set)).to eql('OK')
    end

    it 'returns the default if no value is set' do
      expect(described_class.fetch(:unset, 'OK')).to eql('OK')
    end

    it 'returns a nil default if no value is set' do
      expect(described_class.fetch(:unset, nil)).to be_nil
    end

    it 'raises an exception if no value is set and no default is given' do
      expect {
        described_class.fetch(:unset)
      }.to raise_exception(KeyError)
    end
  end

  describe 'to_param' do
    it 'returns the key' do
      expect(described_class.new(key: 'foo').to_param).to eql('foo')
    end
  end
end
