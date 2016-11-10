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
        Geckoboard::PercentageField.new(:with_additional_info, name: 'With Additional Info'),
        Geckoboard::PercentageField.new(:not_in_team, name: 'Not in any team nor MoJ'),
        Geckoboard::PercentageField.new(:not_in_subteam, name: 'Not in a subteam - i.e. in MoJ')
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
          with_photos: 0.67,
          with_additional_info: 0.67,
          not_in_team: 0.33,
          not_in_subteam: 0.33
        }
      ]
    end

    before do
      create(:person, :with_photo, :department_member, current_project: 'peoplefinder')
      create(:person, :with_photo, :team_member, current_project: nil, description: nil)
      create(:person, description: 'test extra information ')
    end

    include_examples 'returns valid items structure'

    it 'returns expected dataset items' do
      expected_items.each do |item|
        is_expected.to include item
      end
    end
  end

end
