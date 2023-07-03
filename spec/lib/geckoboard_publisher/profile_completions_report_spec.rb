require "rails_helper"

RSpec.describe GeckoboardPublisher::ProfileCompletionsReport, geckoboard: true do
  include PermittedDomainHelper

  it_behaves_like "geckoboard publishable report"

  describe "#fields" do
    subject { described_class.new.fields.map { |field| [field.class, field.id, field.name] } }

    let(:expected_fields) do
      [
        Geckoboard::StringField.new(:team, name: "Team name"),
        Geckoboard::NumberField.new(:total, name: "Total profiles"),
        Geckoboard::PercentageField.new(:with_photos, name: "% profiles with photos"),
        Geckoboard::PercentageField.new(:with_additional_info, name: "% profiles with Additional Info"),
      ].map { |field| [field.class, field.id, field.name] }
    end

    it { is_expected.to eq expected_fields }
  end

  describe "#items" do
    subject(:report_items) { described_class.new.items }

    let(:expected_items) do
      [
        {
          team: "Corporate Services Group",
          total: 1,
          with_photos: 0.0,
          with_additional_info: 1.0,
        },
        {
          team: "Digital Services",
          total: 1,
          with_photos: 1.0,
          with_additional_info: 0.0,
        },
        {
          team: "NOMS",
          total: 2,
          with_photos: 0.5,
          with_additional_info: 0.5,
        },
      ]
    end

    before do
      csg = create :group, name: "Corporate Services Group"
      ds = create :group, name: "Digital Services", acronym: " "
      noms = create :group, name: "National Offender Managment Service", acronym: "NOMS"
      create :person, :member_of, team: csg, description: "description added"
      create :person, :with_photo, :member_of, team: ds, current_project: " \n\t" # test whitespace exclusion
      create :person, :with_photo, :member_of, team: noms, current_project: "mmmmm, donuts!"
      create :person, :member_of, team: noms
    end

    include_examples "returns valid items structure"

    it "uses acronyms if available" do
      expect(report_items).to include_hash_matching team: "NOMS"
      expect(report_items).not_to include_hash_matching team: " \n\t"
    end

    it "returns expected dataset items" do
      expect(report_items.size).to be 3
      expected_items.each do |item|
        expect(report_items).to include item
      end
    end
  end
end
