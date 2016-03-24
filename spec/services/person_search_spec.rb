require 'rails_helper'

RSpec.describe PersonSearch, elastic: true do
  include PermittedDomainHelper

  after(:all) do
    clean_up_indexes_and_tables
  end

  let(:current_project) { 'Current project' }

  let!(:alice) do
    create(:person, given_name: 'Alice', surname: 'Andrews', community: community)
  end
  let!(:bob) do
    create(:person, given_name: 'Bob', surname: 'Browning',
           location_in_building: '10th floor', building: '102 Petty France',
           city: 'London', description: 'weekends only',
           current_project: current_project)
  end
  let!(:andrew) do
    create(:person, given_name: 'Andrew', surname: 'Alice')
  end
  let!(:abraham_kiehn) do
    create(:person, given_name: 'Abraham', surname: 'Kiehn')
  end
  let!(:abe) do
    create(:person, given_name: 'Abe', surname: 'Predovic')
  end
  let!(:oleary) do
    create(:person, given_name: 'Denis', surname: "O'Leary")
  end
  let!(:oleary2) do
    create(:person, given_name: 'Denis', surname: "O’Leary")
  end

  let!(:digital_services) { create(:group, name: 'Digital Services') }
  let!(:membership) { bob.memberships.create(group: digital_services, role: 'Cleaner') }
  let(:community) { create(:community, name: "Poetry") }

  context 'with some people' do
    before do
      Person.import
      Person.__elasticsearch__.client.indices.refresh
    end

    it 'searches by email' do
      results = search_for(alice.email.upcase)
      expect(results).to eq [alice]
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

    it 'searches ignoring * in search term' do
      results = search_for('Alice *')
      expect(results).to include(alice)
    end

    it 'searches ignoring " at start of search term' do
      results = search_for('"Alice ')
      expect(results).to include(alice)
    end

    it 'searches ignoring " at end of search term' do
      results = search_for('Alice"')
      expect(results).to include(alice)
    end

    it 'searches ignoring " in middle of search term' do
      results = search_for('Alice" Andrews')
      expect(results).to include(alice)
    end

    it 'searches apostrophe in name' do
      results = search_for("O'Leary")
      expect(results).to include(oleary)

      results = search_for("O’Leary")
      expect(results).to include(oleary2)
    end

    it 'searches by community' do
      results = search_for(community.name)
      expect(results).to include(alice)
      expect(results).to_not include(bob)
    end

    it 'searches by current project' do
      results = search_for(current_project)
      expect(results).to include(bob)
      expect(results).not_to include(alice)
    end

    it 'returns [] for blank search' do
      results = search_for('')
      expect(results).to eq([])
    end
  end

  context 'with name synonyms above exact match in results' do
    let(:jonathan_smith) { build(:person, given_name: 'Jonathan', surname: 'Smith') }
    let(:john_smith) { build(:person, given_name: 'John', surname: 'Smith') }

    before do
      allow(Person).to receive(:search_results).and_return [jonathan_smith, john_smith]
    end

    it 'sorts results to put exact match first' do
      expect(described_class.new('John Smith').perform_search).to eq [john_smith, jonathan_smith]
    end
  end

  context 'with commas in search query' do
    it 'performs search without commas' do
      expect(Person).to receive(:search_results).with('name:Smith Bill', limit: 100).and_return []
      expect(Person).to receive(:search_results).with('Smith Bill', limit: 100).and_return []
      expect(Person).to receive(:search_results).with(
        hash_including(
          query: {
            fuzzy_like_this: hash_including(like_text: 'Smith Bill')
          }
        ), limit: 100).and_return []

      described_class.new('Smith,Bill,').perform_search
    end
  end

  def search_for(query)
    described_class.new(query).perform_search
  end
end
