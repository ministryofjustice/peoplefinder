require 'rails_helper'

RSpec.describe PersonSearch, elastic: true do
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
  let!(:andrew) {
    create(:person, given_name: 'Andrew', surname: 'Alice')
  }
  let!(:abraham_kiehn) {
    create(:person, given_name: 'Abraham', surname: 'Kiehn')
  }
  let!(:abe) {
    create(:person, given_name: 'Abe', surname: 'Predovic')
  }

  let!(:digital_services) { create(:group, name: 'Digital Services') }
  let!(:membership) { bob.memberships.create(group: digital_services, role: 'Cleaner') }
  let(:community) { create(:community, name: "Poetry") }

  context 'with some people' do
    before do
      Person.import
      Person.__elasticsearch__.client.indices.refresh
    end

    it 'searches by surname' do
      results = search_for('Andrews')
      expect(results).to include(alice)
      expect(results).to_not include(bob)
    end

    it 'searches by given name' do
      results = search_for('Alice')
      expect(results).to include(alice)
      expect(results).to_not include(bob)
    end

    it 'searches by full name' do
      results = search_for('Bob Browning')
      expect(results).to_not include(alice)
      expect(results).to include(bob)
    end

    it 'puts exact match first for "Alice Andrews"' do
      results = search_for('Alice Andrews')
      expect(results).to eq([alice, andrew])
    end

    it 'puts exact match first for "Andrew Alice"' do
      results = search_for('Andrew Alice')
      expect(results).to eq([andrew, alice])
    end

    it 'puts name synonym matches in results' do
      results = search_for('Abe Kiehn')
      expect(results).to eq([abraham_kiehn, abe])
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
    described_class.new.fuzzy_search(query)
  end
end
