require 'rails_helper'

RSpec.describe PersonSearch, elastic: true do
  include PermittedDomainHelper

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

    it 'searches by email' do
      results, exact_match = search_for(alice.email.upcase)
      expect(results).to eq [alice]
      expect(exact_match).to eq true
    end

    it 'searches by surname' do
      results, exact_match = search_for('Andrews')
      expect(results).to include(alice)
      expect(results).to_not include(bob)
      expect(exact_match).to eq true
    end

    it 'searches by given name' do
      results, exact_match = search_for('Alice')
      expect(results).to include(alice)
      expect(results).to_not include(bob)
      expect(exact_match).to eq true
    end

    it 'searches by full name' do
      results, exact_match = search_for('Bob Browning')
      expect(results).to_not include(alice)
      expect(results).to include(bob)
      expect(exact_match).to eq true
    end

    it 'puts exact match first for phrase' do
      results, exact_match = search_for('Digital Project')
      expect(results).to eq([alice, bob])
      expect(exact_match).to eq true
    end

    it 'searches by single word non-name match' do
      results, exact_match = search_for('Digital')
      expect(results).to include(alice)
      expect(results).to include(bob)
      expect(exact_match).to eq true
    end

    it 'puts exact match first for "Alice Andrews"' do
      results, exact_match = search_for('Alice Andrews')
      expect(results).to eq([alice, andrew])
      expect(exact_match).to eq true
    end

    it 'puts exact match first for "Andrew Alice"' do
      results, exact_match = search_for('Andrew Alice')
      expect(results).to eq([andrew, alice])
      expect(exact_match).to eq true
    end

    it 'puts name synonym matches in results' do
      results, exact_match = search_for('Abe Kiehn')
      expect(results).to include(abraham_kiehn)
      expect(results).to include(abe)
      expect(exact_match).to eq false
    end

    it 'puts single name match at top of results when name synonym' do
      results, exact_match = search_for('Abe')
      expect(results.first).to eq(abe)
      expect(exact_match).to eq true
    end

    it 'puts single name match at top of results when first name match' do
      results, exact_match = search_for('Andrew')
      expect(results).to eq([andrew, alice])
      expect(exact_match).to eq true
    end

    it 'searches by group name and membership role' do
      results, exact_match = search_for('Director at digiTAL Services')
      expect(results).to eq([bob, alice])
      expect(exact_match).to eq false
    end

    it 'searches by description and location' do
      results, exact_match = search_for('weekends at petty france office')
      expect(results).to_not include(alice)
      expect(results).to include(bob)
      expect(exact_match).to eq false
    end

    it 'searches ignoring * in search term' do
      results, exact_match = search_for('Alice *')
      expect(results).to include(alice)
      expect(exact_match).to eq true
    end

    it 'searches ignoring " at start of search term' do
      results, exact_match = search_for('"Alice ')
      expect(results).to include(alice)
      expect(exact_match).to eq true
    end

    it 'searches ignoring " at end of search term' do
      results, exact_match = search_for('Alice"')
      expect(results).to include(alice)
      expect(exact_match).to eq true
    end

    it 'searches ignoring " in middle of search term' do
      results, exact_match = search_for('Alice" Andrews')
      expect(results).to include(alice)
      expect(exact_match).to eq true
    end

    it 'searches apostrophe in name' do
      results, exact_match = search_for("O'Leary")
      expect(results).to include(oleary)
      expect(exact_match).to eq true

      results, exact_match = search_for("O’Leary")
      expect(results).to include(oleary2)
      expect(exact_match).to eq true
    end

    it 'searches by current project' do
      results, exact_match = search_for(current_project)
      expect(results).to eq([bob, alice])
      expect(exact_match).to eq true
    end

    it 'searches by partial match and orders by edit distance if edit distance 1 exists' do
      results, exact_match = search_for("John Collie")
      expect(results).to eq([collier, miller, scotti])
      expect(exact_match).to eq false
    end

    it 'searches by partial match and orders by edit distance if edit distance 2 exists' do
      results, exact_match = search_for("John Colli")
      expect(results).to eq([collier, miller, scotti])
      expect(exact_match).to eq false
    end

    it 'searches by partial match and orders by edit distance if edit distance 3 exists' do
      results, exact_match = search_for("John Coll")
      expect(results).to eq([collier, miller, scotti])
      expect(exact_match).to eq false
    end

    it 'returns [] for blank search' do
      results, exact_match = search_for('')
      expect(results).to eq([])
      expect(exact_match).to eq false
    end
  end

  context 'with name synonyms above exact match in results' do
    let(:jonathan_smith) { build(:person, given_name: 'Jonathan', surname: 'Smith') }
    let(:john_smith) { build(:person, given_name: 'John', surname: 'Smith') }

    before do
      allow(Person).to receive(:search_results).and_return [jonathan_smith, john_smith]
    end

    it 'sorts results to put exact match first' do
      results, exact_match = search_for('John Smith')
      expect(results).to eq [john_smith, jonathan_smith]
      expect(exact_match).to eq true
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

      described_class.new('Smith,Bill,').perform_search
    end
  end

  def search_for(query)
    search = described_class.new(query)
    search.perform_search
  end

end
