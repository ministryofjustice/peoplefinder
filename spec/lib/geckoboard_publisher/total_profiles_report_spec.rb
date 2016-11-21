require 'rails_helper'

RSpec.describe GeckoboardPublisher::TotalProfilesReport do
  include PermittedDomainHelper

  it_behaves_like 'geckoboard publishable report'

  describe '#fields' do
    subject { described_class.new.fields.map { |field| [field.class, field.id, field.name] } }

    let(:expected_fields) do
      [
        Geckoboard::NumberField.new(:count, name: 'Count'),
        Geckoboard::DateField.new(:created_at, name: 'Created'),
      ].map { |field| [field.class, field.id, field.name] }
    end

    it { is_expected.to eq expected_fields }
  end

  describe '#items' do
    subject { described_class.new.items }

    let(:expected_items) do
      [
        {
          count: 2,
          created_at: "2015-03-01",
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
      create(:person, created_at: Date.parse('01-MAR-2015 12:43'))
      create(:person, created_at: Date.parse('01-MAR-2015 13:32'))
      create(:person, created_at: Date.parse('21-JUNE-2016'))
      create(:person, created_at: Date.parse('21-AUG-2016'))
    end

    before { Timecop.freeze Date.parse('01-SEP-2016') }
    after { Timecop.return }

    include_examples 'returns valid items structure'

    it 'returns dates to day precision in ISO 8601 format - YYYY-MM-DD' do
      expect(subject.first[:created_at]).to match /^(\d{4}-(0[1-9]|1[12])-((0[1-9]|[12]\d)|3[01]))$/
    end

    it 'returns expected dataset items' do
      expect(subject.size).to eql 3
      expected_items.each do |item|
        is_expected.to include item
      end
    end
  end

end
