require 'rails_helper'

RSpec.describe Deployment, type: :service do
  subject { described_class.new(environment) }

  context 'when all environment variables are available' do
    let(:environment) do
      {
        'VERSION_NUMBER' => '1.2.3',
        'BUILD_DATE' => '2013-04-03',
        'COMMIT_ID' => '7cb26ffe8a2ead47837e28606743e4d31a31512d',
        'BUILD_TAG' => '0.5.25'
      }
    end

    it 'returns a hash of environment information' do
      expected = {
        version_number: '1.2.3',
        build_date: '2013-04-03',
        commit_id: '7cb26ffe8a2ead47837e28606743e4d31a31512d',
        build_tag: '0.5.25'
      }
      expect(subject.info).to eq(expected)
    end
  end

  context 'when environment variables are missing' do
    let(:environment) { {} }

    it 'returns "unknown" for values' do
      expected = {
        version_number: 'unknown',
        build_date: 'unknown',
        commit_id: 'unknown',
        build_tag: 'unknown'
      }
      expect(subject.info).to eq(expected)
    end
  end

  it 'provides a convenient class method' do
    hash = { foo: 'bar' }
    allow_any_instance_of(described_class).to receive(:info).
      and_return(hash)
    expect(described_class.info).to eq(hash)
  end
end
