require 'rails_helper'

RSpec.describe Person, elastic: true do
  include PermittedDomainHelper

  after(:all) do
    clean_up_indexes_and_tables
  end

  let!(:alice) {
    create(:person, given_name: 'Alice', surname: 'Andrews', community: community)
  }
  let!(:bob) {
    create(:person, given_name: 'Bob', surname: 'Browning',
           location_in_building: '10th floor', building: '102 Petty France',
           city: 'London', description: 'weekends only')
  }
  let!(:digital_services) { create(:group, name: 'Digital Services') }
  let!(:membership) { bob.memberships.create(group: digital_services, role: 'Cleaner') }
  let(:community) { create(:community, name: "Poetry") }

  context 'with some people' do
    before do
      described_class.import
      described_class.__elasticsearch__.client.indices.refresh
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
    described_class.fuzzy_search(query).records
  end
end
