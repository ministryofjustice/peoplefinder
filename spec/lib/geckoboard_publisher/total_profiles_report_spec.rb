require 'rails_helper'

RSpec.describe GeckoboardPublisher::TotalProfilesReport do
  include PermittedDomainHelper

  it_behaves_like 'geckoboard publishable report'

  describe '#fields' do
    subject { described_class.new.fields.map { |field| [field.id, field.name] } }

    let(:expected_fields) do
      [
        Geckoboard::NumberField.new(:count, name: 'Count'),
        Geckoboard::DateField.new(:created_at, name: 'Created'),
      ].map { |field| [field.id,field.name] }
    end

    it { is_expected.to eq expected_fields }
  end

  describe '#items' do
    subject { described_class.new.items }

    let(:expected_items) do
      [
        {
          count: 2,
          created_at: "2016-03-01",
        },
        {
          count: 1,
          created_at: "2016-08-21",
        },
        {
          count: 1,
          created_at: "2016-06-21",
        }
      ]
    end

    before do
      create(:person, created_at: Date.parse('28-FEB-2016'))
      create_list(:person, 2, created_at: Date.parse('01-MAR-2016'))
      create(:person, created_at: Date.parse('21-JUNE-2016'))
      create(:person, created_at: Date.parse('21-AUG-2016'))
    end

    before { Timecop.freeze Date.parse('01-SEP-2016') }
    after { Timecop.return }

    it 'returns a geckoboard compatible format' do
      is_expected.to be_an(Array)
      expect(subject.first).to be_a(Hash)
      expect(subject.to_json).to be_a(String)
    end

    it 'returns dates in ISO 8601 format' do
      expect(subject.first[:created_at]).to eql Date.parse('01-MAR-2016').iso8601
    end

    it 'returns profiles created in the last six months only' do
      expect(subject.size).to eql 3
    end

    it 'returns expected dataset items' do
      expected_items.each do |item|
        is_expected.to include item
      end
    end
  end

end
