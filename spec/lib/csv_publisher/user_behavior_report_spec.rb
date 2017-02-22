require 'rails_helper'

RSpec.describe CsvPublisher::UserBehaviorReport, versioning: true do
  include PermittedDomainHelper

  describe '#publish!' do

    let(:file) { Rails.root.join('tmp', 'reports', 'peoplefinder_test_user_behavior_report.csv') }

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

    before do
      File.delete file
    end

    it 'writes the file' do
      expect(File.exist?(file)).to eql false
      report = described_class.new file
      report.publish!
      expect(File.exist?(file)).to eql true
    end
  end
end
