require "rails_helper"

RSpec.describe CsvPublisher::UserBehaviorReport, :csv_report, :versioning do
  include PermittedDomainHelper

  let(:file) { described_class.default_file_path }

  it { is_expected.to respond_to :publish! }
  it { is_expected.to respond_to :file }
  it { is_expected.to respond_to :query }
  it { is_expected.to respond_to :dataset }
  it { expect(described_class).to respond_to :publish! }
  it { expect(described_class).to respond_to :default_file_path }

  describe "#default_file_path" do
    it "returns file name containing app name, environment and report name" do
      expect(described_class.default_file_path.to_path).to include "peoplefinder_test_user_behavior_report"
    end
  end

  describe "#publish!" do
    subject(:publish) { described_class.new.publish! }

    let(:moj) { create :department }
    let(:csg) { create(:group, name: "Corporate Service Group", parent: moj) }
    let(:ds) { create(:group, name: "Digital Services", parent: csg) }

    let(:person_one) do
      person = create :person, given_name: "Joel", surname: "Sugarman", email: "joel.sugarman@digital.justice.gov.uk"
      person.memberships.create!(group: ds, role: "Developer")
      person.memberships.create!(group: ds, role: "Tester")
      person.memberships.create!(group: csg, role: "Business Analyst")
      person
    end
    let(:person_two) do
      create :person, given_name: "John", surname: "Smith", email: "john.smith@digital.justice.gov.uk",
                      login_count: 2, last_login_at: Time.new(2017, 0o5, 21, 2, 2, 2, "+00:00")
    end
    let(:person_three) do
      adrian = create :person, given_name: "Adrian", surname: "Smith", email: "adrian.smith@digital.justice.gov.uk", login_count: 3, last_login_at: Time.new(2016, 0o5, 21, 3, 3, 3, "+00:00")
      adrian.update! location_in_building: "10.51", building: "Fleet Street", city: "Vancouver"
      adrian.update! location_in_building: "10.52", building: "Fleet Street", city: "Vancouver"
      adrian
    end

    before do
      person_one
      person_two
      person_three
    end

    it "returns Report record instance" do
      expect(publish).to be_an_instance_of Report
    end

    it "calls #data on query object" do
      expect_any_instance_of(UserBehaviorQuery).to receive(:data) # rubocop:disable RSpec/AnyInstance
      publish
    end

    it "writes to the specified file" do
      expect { publish }.to have_created_file file
    end
  end
end
