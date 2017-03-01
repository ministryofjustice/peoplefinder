require 'rails_helper'

RSpec.describe CsvPublisher::UserBehaviorReport, versioning: true, csv_report: true do
  include PermittedDomainHelper

  let(:file) { described_class.default_file_path }

  it { is_expected.to respond_to :publish! }
  it { is_expected.to respond_to :file }
  it { is_expected.to respond_to :query }
  it { is_expected.to respond_to :dataset }
  it { expect(described_class).to respond_to :publish! }
  it { expect(described_class).to respond_to :default_file_path }

  describe '#default_file_path' do
    subject { described_class.default_file_path }
    it 'returns file name containing app name, environment and report name' do
      expect(subject.to_path).to include "peoplefinder_test_user_behavior_report"
    end
  end

  describe '#publish!' do
    subject { described_class.new.publish! }

    let(:moj) { create :department}
    let(:csg) { create(:group, name: 'Corporate Service Group', parent: moj) }
    let(:ds) { create(:group, name: 'Digital Services', parent: csg) }

    let!(:person1) do
      person = create :person, given_name: 'Joel', surname: 'Sugarman', email: 'joel.sugarman@digital.justice.gov.uk'
      person.memberships.create(group: ds, role: 'Developer')
      person.memberships.create(group: ds, role: 'Tester')
      person.memberships.create(group: csg, role: 'Business Analyst')
      person
    end
    let!(:person2) do
      create :person, given_name: 'John', surname: 'Smith', email: 'john.smith@digital.justice.gov.uk',
        login_count: 2, last_login_at: Time.new(2017, 05, 21, 2, 2, 2, "+00:00")
    end
    let!(:person3) do
      adrian = create :person, given_name: 'Adrian', surname: 'Smith', email: 'adrian.smith@digital.justice.gov.uk', login_count: 3, last_login_at: Time.new(2016, 05, 21, 3, 3, 3, "+00:00")
      adrian.update! location_in_building: '10.51', building: 'Fleet Street', city: 'Vancouver'
      adrian.update! location_in_building: '10.52', building: 'Fleet Street', city: 'Vancouver'
      adrian
    end

    it 'returns Report record instance' do
      is_expected.to be_an_instance_of Report
    end

    it 'calls #data on query object' do
      expect_any_instance_of(UserBehaviorQuery).to receive(:data)
      subject
    end

    it 'writes to the specified file' do
      expect { subject }.to have_created_file file
    end

  end
end
