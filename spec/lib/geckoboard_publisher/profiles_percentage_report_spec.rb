require 'rails_helper'

RSpec.describe GeckoboardPublisher::ProfilesPercentageReport do
  include PermittedDomainHelper

  it_behaves_like 'geckoboard publishable report'

  describe '#fields' do
    subject { described_class.new.fields.map { |field| [field.id, field.name] } }

    let(:expected_fields) do
      [
        Geckoboard::NumberField.new(:total, name: 'Total'),
        Geckoboard::PercentageField.new(:with_photos, name: 'With Photos'),
        Geckoboard::PercentageField.new(:with_additional_info, name: 'With Additional Info')
      ].map { |field| [field.id,field.name] }
    end

    it { is_expected.to eq expected_fields }
  end

  describe '#items' do
    subject { described_class.new.items }

    let(:expected_items) do
      [
        {
          total: 3,
          with_photos: 66.67,
          with_additional_info: 66.67,
        }
      ]
    end

    before do
      create(:person, :with_photo, current_project: 'peoplefinder')
      create(:person, :with_photo, current_project: nil, description: nil)
      create(:person, description: 'test extra information ')
    end

    it 'returns a geckoboard compatible format' do
      is_expected.to be_an(Array)
      expect(subject.first).to be_a(Hash)
      expect(subject.to_json).to be_a(String)
    end

    it 'returns profiles created in the last six months only' do
      expect(subject.size).to eql 1
    end

    it 'returns expected dataset items' do
      expected_items.each do |item|
        is_expected.to include item
      end
    end
  end

end
