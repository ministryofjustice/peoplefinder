require 'rails_helper'

RSpec.describe 'Searchable', elastic: true do # rubocop:disable RSpec/DescribeClass
  after(:all) do
    clean_up_indexes_and_tables
  end

  context 'with some people' do
    let(:alice) { @alice }
    let(:bob) { @bob }
    let(:community) { @community }

    before(:all) do
      @community = create(:community, name: "Poetry")
      @alice = create(:person,
        given_name: 'Alice', surname: 'Andrews', community: @community
      )
      @bob = create(:person,
        given_name: 'Bob', surname: 'Browning',
        location_in_building: '10th floor', building: '102 Petty France',
        city: 'London', description: 'weekends only'
      )
      digital_services = create(:group, name: 'Digital Services')
      @bob.memberships.create(group: digital_services, role: 'Cleaner')
      Peoplefinder::Person.import
      Peoplefinder::Person.__elasticsearch__.client.indices.refresh
      sleep 2
    end

    after(:all) do
      DatabaseCleaner.clean
    end

    it 'searches by surname' do
      results = search_for('Andrews')
      expect(results).to include(alice)
      expect(results).to_not include(bob)
    end

    it 'searches by name' do
      results = search_for('Alice')
      expect(results).to include(alice)
      expect(results).to_not include(bob)
    end

    it 'searches by given_name' do
      results = search_for('Bob Browning')
      expect(results).to_not include(alice)
      expect(results).to include(bob)
    end

    it 'searches using common name abbreviations' do
      results = search_for('Robert')
      expect(results).to_not include(alice)
      expect(results).to include(bob)
    end

    it 'searches by group name and membership role' do
      results = search_for('Cleaner at digiTAL Services')
      expect(results).to_not include(alice)
      expect(results).to include(bob)
    end

    it 'searches by description and location' do
      results = search_for('weekends at petty france office')
      expect(results).to_not include(alice)
      expect(results).to include(bob)
    end

    it 'searches by community' do
      results = search_for(community.name)
      expect(results).to include(alice)
      expect(results).to_not include(bob)
    end
  end

  def search_for(query)
    Peoplefinder::Person.fuzzy_search(query).records
  end
end
