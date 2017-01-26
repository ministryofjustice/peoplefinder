require 'rails_helper'
require_relative 'shared_examples_for_search'

RSpec.describe PersonSearch, elastic: true do
  include PermittedDomainHelper

  describe '.perform_search' do
    after(:all) do
      clean_up_indexes_and_tables
    end

    let(:current_project) { 'Current project' }

    let!(:alice) do
      create(:person, given_name: 'Alice', surname: 'Andrews',
        description: 'digital project')
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

    let!(:collier) do
      create(:person, given_name: 'John', surname: "Collier")
    end
    let!(:miller) do
      create(:person, given_name: 'John', surname: "Miller")
    end
    let!(:scotti) do
      create(:person, given_name: 'John', surname: "Scotti")
    end

    let!(:digital_services) { create(:group, name: 'Digital Services') }
    let!(:membership) { bob.memberships.create(group: digital_services, role: 'Digital Director') }

    context 'with some people' do
      before do
        Person.import
        Person.__elasticsearch__.client.indices.refresh
      end

      it_behaves_like 'a search'

      it 'searches by email' do
        results = search_for(alice.email.upcase)
        expect(results.set).to eq [alice]
        expect(results.contains_exact_match).to eq true
      end

      it 'searches by surname' do
        results = search_for('Andrews')
        expect(results.set).to include(alice)
        expect(results.set).to_not include(bob)
        expect(results.contains_exact_match).to eq true
      end

      it 'searches by given name' do
        results = search_for('Alice')
        expect(results.set).to include(alice)
        expect(results.set).to_not include(bob)
        expect(results.contains_exact_match).to eq true
      end

      it 'searches by full name' do
        results = search_for('Bob Browning')
        expect(results.set).to_not include(alice)
        expect(results.set).to include(bob)
        expect(results.contains_exact_match).to eq true
      end

      it 'puts exact match first for phrase' do
        results = search_for('Digital Project')
        expect(results.set).to eq([alice, bob])
        expect(results.contains_exact_match).to eq true
      end

      it 'searches by single word non-name match' do
        results = search_for('Digital')
        expect(results.set).to include(alice)
        expect(results.set).to include(bob)
        expect(results.contains_exact_match).to eq true
      end

      it 'puts exact match first for "Alice Andrews"' do
        results = search_for('Alice Andrews')
        expect(results.set).to eq([alice, andrew])
        expect(results.contains_exact_match).to eq true
      end

      it 'puts exact match first for "Andrew Alice"' do
        results = search_for('Andrew Alice')
        expect(results.set).to eq([andrew, alice])
        expect(results.contains_exact_match).to eq true
      end

      it 'puts name synonym matches in results' do
        results = search_for('Abe Kiehn')
        expect(results.set).to include(abraham_kiehn)
        expect(results.set).to include(abe)
        expect(results.contains_exact_match).to eq false
      end

      it 'puts single name match at top of results when name synonym' do
        results = search_for('Abe')
        expect(results.set.first).to eq(abe)
        expect(results.contains_exact_match).to eq true
      end

      it 'puts single name match at top of results when first name match' do
        results = search_for('Andrew')
        expect(results.set).to eq([andrew, alice])
        expect(results.contains_exact_match).to eq true
      end

      it 'searches by group name and membership role' do
        results = search_for('Director at digiTAL Services')
        expect(results.set).to eq([bob, alice])
        expect(results.contains_exact_match).to eq false
      end

      it 'searches by description and location' do
        results = search_for('weekends at petty france office')
        expect(results.set).to_not include(alice)
        expect(results.set).to include(bob)
        expect(results.contains_exact_match).to eq false
      end

      it 'searches ignoring * in search term' do
        results = search_for('Alice *')
        expect(results.set).to include(alice)
        expect(results.contains_exact_match).to eq true
      end

      it 'searches ignoring " at start of search term' do
        results = search_for('"Alice ')
        expect(results.set).to include(alice)
        expect(results.contains_exact_match).to eq true
      end

      it 'searches ignoring " at end of search term' do
        results = search_for('Alice"')
        expect(results.set).to include(alice)
        expect(results.contains_exact_match).to eq true
      end

      it 'searches ignoring " in middle of search term' do
        results = search_for('Alice" Andrews')
        expect(results.set).to include(alice)
        expect(results.contains_exact_match).to eq true
      end

      it 'searches apostrophe in name' do
        results = search_for("O'Leary")
        expect(results.set).to include(oleary)
        expect(results.contains_exact_match).to eq true

        results = search_for("O’Leary")
        expect(results.set).to include(oleary2)
        expect(results.contains_exact_match).to eq true
      end

      it 'searches by current project' do
        results = search_for(current_project)
        expect(results.set).to eq([bob, alice])
        expect(results.contains_exact_match).to eq true
      end

      it 'searches by partial match and orders by edit distance if edit distance 1 exists' do
        results = search_for("John Collie")
        expect(results.set).to eq([collier, miller, scotti])
        expect(results.contains_exact_match).to eq false
      end

      it 'searches by partial match and orders by edit distance if edit distance 2 exists' do
        results = search_for("John Colli")
        expect(results.set.first).to eq(collier)
        expect(results.set).to include(miller) # has edit distance of 4 from query term
        expect(results.set).to include(scotti) # also has edit distance of 4 from query term
        expect(results.contains_exact_match).to eq false
      end

      it 'searches by partial match and orders by edit distance if edit distance 3 exists' do
        results = search_for("John Coll")
        expect(results.set).to eq([collier, miller, scotti])
        expect(results.contains_exact_match).to eq false
      end

      it 'returns [] for blank search' do
        results = search_for('')
        expect(results.set).to eq([])
        expect(results.contains_exact_match).to eq false
      end
    end

    context 'with name synonyms above exact match in results' do
      let(:jonathan_smith) { build(:person, given_name: 'Jonathan', surname: 'Smith') }
      let(:john_smith) { build(:person, given_name: 'John', surname: 'Smith') }

      before do
        allow(Person).to receive(:search_results).and_return [jonathan_smith, john_smith]
      end

      it 'sorts results to put exact match first' do
        results = search_for('John Smith')
        expect(results.set).to eq [john_smith, jonathan_smith]
        expect(results.contains_exact_match).to eq true
      end
    end

    context 'with commas in search query' do
      it 'performs search without commas' do
        expect(Person).to receive(:search_results).with('"Smith Bill"', limit: 100).and_return []
        expect(Person).to receive(:search_results).with('Smith Bill', limit: 100).and_return []
        expect(Person).to receive(:search_results).with(
          hash_including(
            query: {
              multi_match: hash_including(query: 'Smith Bill')
            }
          ), limit: 100).and_return []

        search_for('Smith,Bill,')
      end
    end
  end

  describe '.exact_name_matches' do
    let(:jonathan_smith) { build(:person, given_name: 'Jonathan', surname: 'Smith') }
    let(:john_smith) { build(:person, given_name: 'John', surname: 'Smith') }

    before do
      allow(Person).to receive(:search_results).and_return [jonathan_smith, john_smith]
    end

    it 'returns case-insensitive exact matches based on name alone' do
      search_for('john smith') do |searcher|
        expect(searcher.exact_name_matches.map(&:name)).to eq [john_smith].map(&:name)
      end
    end
  end

  def results_struct
    SearchResults.new
  end

  def search_for(query)
    searcher = described_class.new(query, results_struct)
    results = searcher.perform_search
    yield searcher if block_given?
    results
  end

end
