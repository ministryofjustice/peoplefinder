require 'rails_helper'

RSpec.describe ReadonlyUser, type: :model do
  subject { described_class.new }

  describe '.from_request' do
    let(:headers) { {} }
    let(:request) { double(headers: headers) }

    subject { described_class.from_request(request) }

    # the header name and value is defined in .env for test
    context 'when readonly header is set' do
      context 'when the value is correct' do
        let(:headers) { { 'HTTP_RO' => 'ENABLED' } }

        it { is_expected.to be_a(ReadonlyUser) }
      end

      context 'for any other value' do
        let(:headers) { { 'HTTP_RO' => 'OTHER' } }

        it { is_expected.to be nil }
      end
    end

    context 'when readonly header is not set' do
      it { is_expected.to be nil }
    end
  end

  describe '#id' do
    it 'returns :readonly' do
      expect(subject.id).to be :readonly
    end
  end

  describe '#super_admin?' do
    it 'returns false' do
      expect(subject).not_to be_super_admin
    end
  end
end
