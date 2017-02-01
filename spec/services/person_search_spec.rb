require 'rails_helper'
require_relative 'shared_examples_for_search'

RSpec.describe PersonSearch, elastic: true do

  before(:all) do
    clean_up_indexes_and_tables
    PermittedDomain.find_or_create_by(domain: 'digital.justice.gov.uk')
    @alice = create(:person, given_name: 'Alice', surname: 'Andrews', description: 'digital project')
    @bob = create(:person, given_name: 'Bob', surname: 'Browning',
             location_in_building: '10th floor', building: '102 Petty France',
             city: 'London', description: 'weekends only',
             current_project: 'Current project')
    @andrew = create(:person, given_name: 'Andrew', surname: 'Alice')
    @abraham_kiehn = create(:person, given_name: 'Abraham', surname: 'Kiehn')
    @abe = create(:person, given_name: 'Abe', surname: 'Predovic')
    @oleary = create(:person, given_name: 'Denis', surname: "O'Leary")
    @oleary2 = create(:person, given_name: 'Denis', surname: "O’Leary")
    @collier = create(:person, given_name: 'John', surname: "Collier")
    @miller = create(:person, given_name: 'John', surname: "Miller")
    @scotti = create(:person, given_name: 'John', surname: "Scotti")
    digital_services = create(:group, name: 'Digital Services')
    @bob.memberships.create(group: digital_services, role: 'Digital Director')

    @john_smith = create(:person, given_name: 'John', surname: 'Smith')
    @jonathan_smith = create(:person, given_name: 'Jonathan', surname: 'Smith')

    @john_smyth = create(:person, given_name: 'John', surname: 'Smyth')
    create(:membership, person: @john_smyth, group: digital_services, role: 'Content')

    @peter_smithson = create(:person, given_name: 'Peter', surname: 'Smithson')
    @pete_smithson = create(:person, given_name: 'Pete', surname: 'Smithson')
    @peter_smithson_pa = create(:person, given_name: 'Harold', surname: 'Jone', description: 'PA to Peter Smithson')

    @steve_richards = create(:person, given_name: 'Steve', surname: 'Richards', current_project: 'PF')
    @steven_richards = create(:person, given_name: 'Steven', surname: 'Richards')
    @stephen_richards = create(:person, given_name: 'Stephen', surname: 'Richards')
    @steve_richardson = create(:person, given_name: 'Steve', surname: 'Richardson')
    @steven_richardson = create(:person, given_name: 'Steven', surname: 'Richardson')
    @stephen_richardson = create(:person, given_name: 'Stephen', surname: 'Richardson')
    @john_richards = create(:person, given_name: 'John', surname: 'Richards')
    @steve_edmundson = create(:person, given_name: 'Steve', surname: 'Edmundson')
    @stephen_edmundson = create(:person, given_name: 'Stephen', surname: 'Edmundson')
    @john_richardson = create(:person, given_name: 'John', surname: 'Richardson')
    @john_edmundson = create(:person, given_name: 'John', surname: 'Edmundson') # should not appea
    @jane_medurst = create(:person, given_name: 'Jane', surname: 'Medurst')
    @steve_richards_pa = create(:person, given_name: 'Personal', surname: 'Assistant', description: 'PA to Steve Richards')

    Person.import force: true
    Person.__elasticsearch__.refresh_index!
  end

  after(:all) do
    clean_up_indexes_and_tables
  end

  context 'with some people' do
    it_behaves_like 'a search'

    it 'searches by email' do
      results = search_for(@alice.email.upcase)
      expect(results.set).to eq [@alice]
      expect(results.contains_exact_match).to eq true
    end

    it 'searches by surname' do
      results = search_for('Andrews')
      expect(results.set).to include(@alice)
      expect(results.set).to_not include(@bob)
      expect(results.contains_exact_match).to eq true
    end

    it 'searches by given name' do
      results = search_for('Alice')
      expect(results.set).to include(@alice)
      expect(results.set).to_not include(@bob)
      expect(results.contains_exact_match).to eq true
    end

    it 'searches by full name' do
      results = search_for('Bob Browning')
      expect(results.set.map(&:name)).to_not include(@alice.name)
      expect(results.set.map(&:name)).to include(@bob.name)
      expect(results.contains_exact_match).to eq true
    end

    it 'puts exact match first for phrase' do
      results = search_for('Digital Project')
      expect(results.set.map(&:name)).to eq([@alice, @bob, @john_smyth].map(&:name))
      expect(results.contains_exact_match).to eq true
    end

    it 'searches by single word non-name match' do
      results = search_for('Digital')
      expect(results.set).to include(@alice)
      expect(results.set).to include(@bob)
      expect(results.contains_exact_match).to eq true
    end

    it 'puts exact match first for "Alice Andrews"' do
      results = search_for('Alice Andrews')
      expect(results.set).to eq([@alice, @andrew])
      expect(results.contains_exact_match).to eq true
    end

    it 'puts exact match first for "Andrew Alice"' do
      results = search_for('Andrew Alice')
      expect(results.set).to eq([@andrew, @alice])
      expect(results.contains_exact_match).to eq true
    end

    it 'puts name synonym matches in results' do
      results = search_for('Abe Kiehn')
      expect(results.set).to include(@abraham_kiehn)
      expect(results.set).to include(@abe)
      expect(results.contains_exact_match).to eq false
    end

    it 'puts single name match at top of results when name synonym' do
      results = search_for('Abe')
      expect(results.set.first).to eq(@abe)
      expect(results.contains_exact_match).to eq true
    end

    it 'puts single name match at top of results when first name match' do
      results = search_for('Andrew')
      expect(results.set).to eq([@andrew, @alice])
      expect(results.contains_exact_match).to eq true
    end

    it 'searches by group name and membership role' do
      results = search_for('Director at digiTAL Services')
      expect(results.set.map(&:name)).to eq([@bob, @john_smyth, @alice].map(&:name))
      expect(results.contains_exact_match).to eq false
    end

    it 'searches by description and location' do
      results = search_for('weekends at petty france office')
      expect(results.set).to_not include(@alice)
      expect(results.set).to include(@bob)
      expect(results.contains_exact_match).to eq false
    end

    it 'searches ignoring * in search term' do
      results = search_for('Alice *')
      expect(results.set).to include(@alice)
      expect(results.contains_exact_match).to eq true
    end

    it 'searches ignoring " at start of search term' do
      results = search_for('"Alice ')
      expect(results.set).to include(@alice)
      expect(results.contains_exact_match).to eq true
    end

    it 'searches ignoring " at end of search term' do
      results = search_for('Alice"')
      expect(results.set).to include(@alice)
      expect(results.contains_exact_match).to eq true
    end

    it 'searches ignoring " in middle of search term' do
      results = search_for('Alice" Andrews')
      expect(results.set).to include(@alice)
      expect(results.contains_exact_match).to eq true
    end

    it 'searches apostrophe in name' do
      results = search_for("O'Leary")
      expect(results.set).to include(@oleary)
      expect(results.contains_exact_match).to eq true

      results = search_for("O’Leary")
      expect(results.set).to include(@oleary2)
      expect(results.contains_exact_match).to eq true
    end

    it 'searches by current project' do
      results = search_for('Current project')
      expect(results.set).to eq([@bob, @alice])
      expect(results.contains_exact_match).to eq true
    end

    it 'searches by partial match and orders by edit distance if edit distance 1 exists' do
      results = search_for("John Collie")
      expect(results.set[0..2].map(&:name)).to eq([@collier, @miller, @scotti].map(&:name))
      expect(results.contains_exact_match).to eq false
    end

    it 'searches by partial match and orders by edit distance if edit distance 2 exists' do
      results = search_for("John Colli")
      expect(results.set.first.name).to eq(@collier.name)
      expect(results.set.map(&:name)).to include(@miller.name) # has edit distance of 4 from query term
      expect(results.set.map(&:name)).to include(@scotti.name) # also has edit distance of 4 from query term
      expect(results.contains_exact_match).to eq false
    end

    it 'searches by partial match and orders by edit distance if edit distance 3 exists' do
      results = search_for("John Coll")
      expect(results.set.map(&:name)).to include(*[@collier, @miller, @scotti].map(&:name))
      expect(results.contains_exact_match).to eq false
    end

    it 'returns [] for blank search' do
      results = search_for('')
      expect(results.set).to eq([])
      expect(results.contains_exact_match).to eq false
    end
  end

  context 'performs several searches' do
    it '- phrase name search' do
      expect_any_instance_of(described_class).to receive(:phrase_name_search).and_return []
      search_for('Smith Bill')
    end

    it '- phrase search' do
      expect_any_instance_of(described_class).to receive(:phrase_search).and_return []
      search_for('Smith Bill')
    end

    it '- fuzzy search' do
      expect_any_instance_of(described_class).to receive(:fuzzy_search).and_return []
      search_for('Smith Bill')
    end
  end

  context 'with symbol characters in search query' do
    it 'replaces commas with single whitespace and strips whitespace from ends' do
      search_for(',Smith,Bill,') do |searcher|
        expect(searcher.query).to eql 'Smith Bill'
      end
    end
    it 'replaces all other non-alpha-numeric characters as single whitespace' do
      search_for('\Smith\?Bill*&£23@%') do |searcher|
        expect(searcher.query).to eql 'Smith Bill 23'
      end
    end
  end

  describe '.phrase_name_matches' do
    let(:query) { 'john smith' }

    it 'returns case-insensitive exact matches based on name alone' do
      search_for(query) do |searcher|
        expect(searcher.phrase_name_matches.first.name).to eql @john_smith.name
      end
    end

    it 'returns synonymous names as if exact' do
      search_for(query) do |searcher|
        expect(searcher.phrase_name_matches.second.name).to eql @jonathan_smith.name
      end
    end
  end

  describe '.phrase_matches' do
    let(:query) { 'Peter Smithson' }

    it 'returns documents matching exact phrase in any indexed field' do
      search_for(query) do |searcher|
        expect(searcher.phrase_matches.map(&:name)).to match_array [@peter_smithson.name, @peter_smithson_pa.name]
      end
    end

    it 'does not include synonymous names' do
      search_for(query) do |searcher|
        expect(searcher.phrase_matches.map(&:name)).not_to include @pete_smithson.name
      end
    end
  end

  describe '.fuzzy_matches' do
    let(:query) { 'Digital Developer' }

    it 'returns documents where one or more tokens found in one or more of the indexed fields incl. role and group' do
      search_for('Digital Developer') do |searcher|
        expect(searcher.fuzzy_matches.map(&:name)).to include @john_smyth.name
      end
      search_for('Content') do |searcher|
        expect(searcher.fuzzy_matches.map(&:name)).to include @john_smyth.name
      end
    end
  end

  describe 'Search weighting' do
    describe 'Steve\'s Scenario' do
      subject(:results) { search_for(query) }

      context 'search for given and last name' do
        let(:query) { 'Steve Richards' }

        let(:expected_steves) do
          @expected_steves = [
            @steve_richards,
            @steven_richards,
            @stephen_richards,
            @steve_richards_pa,
            @steve_richardson,
            @steven_richardson,
            @stephen_richardson,
            @john_richards
          ].map(&:name)
        end

        it 'test has expected records and ES index documents' do
          expect(Person.count).to eql 29
          expect(Person.search('*').results.total).to eql 29
        end

        it 'returns person with exact first name and surname first' do
          expect(results.set.first.name).to eql 'Steve Richards'
        end

        it 'returns people with synonyms of first name and exact surname in second batch, ordered alphabetically' do
          expect(results.set[1..2].map(&:name)).to match_array ['Stephen Richards', 'Steven Richards']
        end

        it 'returns people with exact name but NOT in name field in third batch' do
          expect(results.set[3].name).to eql 'Personal Assistant'
        end

        it 'returns people with exact first name and similar surname in fourth batch' do
          expect(results.set[4].name).to eql 'Steve Richardson'
        end

        it 'returns people with synonymous first name and similar surname in fifth batch' do
          expect(results.set[5..7].map(&:name)).to match_array ['Steven Richardson', 'Stephen Richardson', 'John Richards']
        end

        xit 'returns people with different first name and exact surname in seventh batch' do
          expect(results.set[7].name).to eql 'John Richards'
        end

        xit 'returns people in expected order' do
          pending 'need to sort out flickers'
          expect(results.set[0..7].map(&:name)).to eql expected_steves
        end
      end

      context 'search for given name only' do
        let(:query) { 'Steve' }
        let(:expected_steves) { %w(Steve Steven Stephen Personal) }

        it 'returns people in order of given names distance from exact name' do
          actual_steves = results.set.map(&:name).map(&:split).map(&:first).uniq
          expect(actual_steves).to match_array expected_steves
          expect(actual_steves.last).to eql expected_steves.last
        end
      end

      context 'search for surname only' do
        let(:query) { 'Richards' }
        let(:expected_richards) { %w(John Steven Stephen Steve Personal) }

        # given name order is unhandled by code
        it 'returns people with only the surname richards as name or, less importantly, in another field' do
          actual_richards = results.set.map(&:name).map(&:split).map(&:first).uniq
          expect(actual_richards).to match_array expected_richards
          expect(actual_richards.last).to eql expected_richards.last
        end
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
