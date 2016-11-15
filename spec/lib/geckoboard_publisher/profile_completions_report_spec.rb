require 'rails_helper'

RSpec.describe GeckoboardPublisher::ProfileCompletionsReport do
  include PermittedDomainHelper

  it_behaves_like 'geckoboard publishable report'

  describe '#fields' do
    subject { described_class.new.fields.map { |field| [field.id, field.name] } }

    let(:expected_fields) do
      [
        Geckoboard::StringField.new(:date, name: 'Name'),
        Geckoboard::NumberField.new(:create, name: 'Total'),
        Geckoboard::NumberField.new(:update, name: 'With photos'),
        Geckoboard::NumberField.new(:destroy, name: 'With Additional Info')
      ].map { |field| [field.id,field.name] }
    end

    it { is_expected.to eq expected_fields }
  end

  describe '#items' do
    subject { described_class.new.items }

    let(:expected_items) do
      [
        {
          team: "Corporate Services Group",
          total: 1,
          with_photos: 0,
          with_additional_info: 1
        },
        {
          team: "Digital Services",
          total: 1,
          with_photos: 1,
          with_additional_info: 0
        },
        {
          team: "NOMS",
          total: 1,
          with_photos: 1,
          with_additional_info: 1
        }
      ]
    end

    before do
      csg = create :group, name: 'Corporate Services Group'
      ds = create :group, name: 'Digital Services', acronym: ' '
      noms = create :group, name: 'National Offender Managment Service', acronym: 'NOMS'
      person = create :person, :member_of, team: csg, description: 'description added'
      person = create :person, :with_photo, :member_of, team: ds, current_project: " \n\t" # test whitespace exclusion
      person = create :person, :with_photo, :member_of, team: noms, current_project: "mmmmm, donuts!"
    end

    include_examples 'returns valid items structure'

    it 'uses acronyms if not blank' do
      is_expected.to include_hash_matching team: 'NOMS'
      is_expected.not_to include_hash_matching team: ' '
    end

    it 'returns expected dataset items' do
      expect(subject.size).to eql 3
      expected_items.each do |item|
        is_expected.to include item
      end
    end

  end

end
