require 'rails_helper'

RSpec.describe GeckoboardPublisher::ProfilesPercentageReport, geckoboard: true do
  include PermittedDomainHelper

  it_behaves_like 'geckoboard publishable report'

  describe '#fields' do
    subject { described_class.new.fields.map { |field| [field.class, field.id, field.name] } }

    let(:expected_fields) do
      [
        Geckoboard::PercentageField.new(:with_photos, name: 'With Photos'),
        Geckoboard::PercentageField.new(:with_additional_info, name: 'With Additional Info'),
        Geckoboard::PercentageField.new(:not_in_team, name: 'Not in any team nor DIT'),
        Geckoboard::PercentageField.new(:not_in_subteam, name: 'Not in a subteam - i.e. in DIT'),
        Geckoboard::PercentageField.new(:not_in_tip_team, name: 'Not in a branch tip team - e.g. at Agency level'),
        Geckoboard::PercentageField.new(:not_edited, name: 'Never been edited')
      ].map { |field| [field.class, field.id, field.name] }
    end

    it { is_expected.to eq expected_fields }
  end

  describe '#items', versioning: true do
    subject { described_class.new.items }

    let(:expected_items) do
      [
        {
          with_photos: 0.67,
          with_additional_info: 0.67,
          not_in_team: 0.33,
          not_in_subteam: 0.33,
          not_in_tip_team: 0.33,
          not_edited: 0.67
        }
      ]
    end

    before do
      create(:person, :with_photo, current_project: 'peoplefinder')
      create(:person, :with_photo, :team_member, current_project: nil, description: " \t\n").tap do |person|
        person.memberships.find_by(group_id: Group.department.id).destroy
      end

      create(:person, description: 'test extra information ').tap do |person|
        person.update(given_name: 'Joe')
        person.memberships.destroy_all
      end
    end

    include_examples 'returns valid items structure'

    it 'returns expected dataset items' do
      expected_items.each do |item|
        is_expected.to include item
      end
    end
  end

end
