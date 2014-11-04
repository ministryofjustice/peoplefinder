require 'rails_helper'
require 'peoplefinder/search_index'

RSpec.describe Peoplefinder::SearchIndex, elastic: true do # rubocop:disable RSpec/DescribeClass
  after(:all) do
    clean_up_indexes_and_tables
  end

  subject(:search_index) { described_class.new }

  let!(:alice) { create(:person, given_name: 'Alice', surname: 'Andrews') }
  let!(:bob) { create(:person, given_name: 'Bob', surname: 'Browning', location: 'Petty France 10th floor', description: 'weekends only') }
  let!(:digital_services) { create(:group, name: 'Digital Services') }
  let!(:membership) { bob.memberships.create(group: digital_services, role: 'Cleaner') }

  context 'with some people' do
    before do
      search_index.import(Peoplefinder::Person.all)
      search_index.flush
    end

    it 'searches by surname' do
      results = search_index.search('Andrews')
      expect(results).to include(alice)
      expect(results).to_not include(bob)
    end

    it 'searches by name' do
      results = search_index.search('Alice')
      expect(results).to include(alice)
      expect(results).to_not include(bob)
    end

    it 'searches by given_name' do
      results = search_index.search('Bob Browning')
      expect(results).to_not include(alice)
      expect(results).to include(bob)
    end

    it 'searches by group name and membership role' do
      results = search_index.search('Cleaner at digiTAL Services')
      expect(results).to_not include(alice)
      expect(results).to include(bob)
    end

    it 'searches by description and location' do
      results = search_index.search('weekends at petty france office')
      expect(results).to_not include(alice)
      expect(results).to include(bob)
    end
  end
end
