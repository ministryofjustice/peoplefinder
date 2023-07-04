require "rails_helper"

RSpec.describe PersonChangesPresenter, type: :presenter do
  include PermittedDomainHelper

  subject(:presenter) { described_class.new(person.changes) }

  let(:old_email) { "test.user@digital.justice.gov.uk" }
  let(:new_email) { "changed.user@digital.justice.gov.uk" }
  let(:person) do
    create(
      :person,
      email: old_email,
      location_in_building: "10.51",
      description: nil,
    )
  end

  it_behaves_like "a changes_presenter"

  describe "delegation" do
    before { person.email = new_email }

    it "delegates [] to #changes" do
      expect(presenter[:email]).to eq presenter.changes[:email]
    end
  end

  describe "#raw" do
    subject(:raw) { described_class.new(person.changes).raw }

    before { person.email = new_email }

    it "returns orginal changes" do
      expect(raw).to be_a Hash
      expect(raw[:email].first).to eql old_email
    end
  end

  describe "#changes" do
    subject(:changes) { described_class.new(person.changes).changes }

    let(:valid_format) do
      {
        email: { raw: [old_email, new_email], message: "Changed your email from #{old_email} to #{new_email}" },
        location_in_building: { raw: ["10.51", ""], message: "Removed the location in building" },
        primary_phone_number: { raw: [nil, "01234, 567 890"], message: "Added a primary phone number" },
      }
    end

    let(:valid_workdays) do
      {
        work_days:
          { raw:
            { works_saturday: [false, true],
              works_monday: [true, false] },
            message: "Changed your working days" },
      }
    end

    before do
      person.email = new_email
      person.location_in_building = ""
      person.primary_phone_number = "01234, 567 890"
      person.description = ""
    end

    it_behaves_like "#changes on changes_presenter"

    it "returns expected format of data" do
      expect(changes).to eql valid_format
    end

    it "ignores empty strings as changes" do
      expect(changes).not_to have_key :description
    end

    it "returns single message for work days" do
      person.works_saturday = true
      person.works_monday = false
      expect(changes).to include valid_workdays
    end
  end

  describe "#serialize" do
    subject(:serialized) { described_class.new(person.changes).serialize }

    let(:valid_json_hash) do
      {
        data: {
          raw: {
            email: [old_email, new_email],
          },
        },
      }
    end

    before do
      person.email = "changed.user@digital.justice.gov.uk"
      person.location_in_building = ""
      person.primary_phone_number = " 01234, 567 890"
      person.description = ""
    end

    include_examples "serializability"

    it "returns JSON of raw changes only" do
      expect(serialized).to include_json(valid_json_hash)
      expect(serialized).not_to include_json(message: "Changed email from #{old_email} to #{new_email}")
    end
  end
end
