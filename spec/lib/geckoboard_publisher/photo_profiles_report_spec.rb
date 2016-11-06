require 'rails_helper'

RSpec.describe GeckoboardPublisher::PhotoProfilesReport do
  include PermittedDomainHelper

  it_behaves_like 'geckoboard publishable report'

  describe '#fields' do
    subject { described_class.new.fields.map { |field| [field.id, field.name] } }

    let(:expected_fields) do
      [
        Geckoboard::NumberField.new(:count, name: 'Count'),
        Geckoboard::DateField.new(:photo_added_at, name: 'Photo Added'),
      ].map { |field| [field.id,field.name] }
    end

    it { is_expected.to eq expected_fields }
  end

  describe '#items' do
    subject { described_class.new.items }

    let(:expected_items) do
      [
        {
          count: 1,
          photo_added_at: "2015-02-28",
        },
        {
          count: 2,
          photo_added_at: "2015-03-01",
        },
        {
          count: 1,
          photo_added_at: "2016-06-21",
        }
      ]
    end

    before do
      Timecop.freeze(Date.parse('28-FEB-2015')) { create(:person, :with_photo) }
      Timecop.freeze(Date.parse('28-FEB-2015')) { create(:person) }
      Timecop.freeze(Date.parse('01-MAR-2015 12:55')) { create(:person, :with_photo) }
      Timecop.freeze(Date.parse('01-MAR-2015 13:01')) { create(:person, :with_photo) }
      Timecop.freeze(Date.parse('21-JUN-2016')) { create(:person, :with_photo) }
    end

    before { Timecop.freeze Date.parse('01-SEP-2016') }
    after { Timecop.return }

    it 'returns a geckoboard compatible format' do
      is_expected.to be_an(Array)
      expect(subject.first).to be_a(Hash)
      expect(subject.to_json).to be_a(String)
    end

    it 'returns dates in ISO 8601 format' do
      expect(subject.first[:photo_added_at]).to eql Date.parse('28-FEB-2015').iso8601
    end

    it 'returns profiles with photos added regardless of how old they are' do
      expect(subject.size).to eql 3
    end

    xit 'returns profiles with legacy photos too' do
      Timecop.freeze(Date.parse('28-FEB-2015')) { create(:person, image: File.open(sample_image)) }
      expect(subject.size).to eql 4
    end

    it 'returns expected dataset items' do
      expected_items.each do |item|
        is_expected.to include item
      end
    end
  end

end
