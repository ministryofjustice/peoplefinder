require 'rails_helper'
require_relative 'shared_examples_for_search'

RSpec.describe PersonSearch, elastic: true do

  before(:all) do
    clean_up_indexes_and_tables
    PermittedDomain.find_or_create_by(domain: 'digital.justice.gov.uk')
    @alice = create(:person, given_name: 'Alice', surname: 'Andrews', current_project: 'digital project')
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
    Person.import force: true
    Person.__elasticsearch__.refresh_index!
  end

  after(:all) do
    clean_up_indexes_and_tables
  end

  context 'with some people' do

    it_behaves_like 'a search'

    it 'searches by email' do
      pending "TODO CT-2691 - commented out test to get ES update working"
      results = search_for(@alice.email.upcase)
      expect(results.set.first.name).to eq @alice.name
      expect(results.contains_exact_match).to eq true
    end

    it 'searches by surname' do
      results = search_for('Andrews')
      expect(results.set.map(&:name)).to match_array [@alice.name, @andrew.name]
      expect(results.contains_exact_match).to eq true
    end

    it 'searches by given name' do
      results = search_for('Alice')
      expect(results.set.map(&:name)).to match_array [@alice.name, @andrew.name]
      expect(results.contains_exact_match).to eq true
    end

    it 'searches by full name' do
      results = search_for('Bob Browning')
      expect(results.set.map(&:name)).to_not include(@alice.name)
      expect(results.set.map(&:name)).to include(@bob.name)
      expect(results.contains_exact_match).to eq true
    end

    it 'searches by single word non-name match' do
      results = search_for('Digital')
      expect(results.set.map(&:name)).to match_array [@alice.name, @bob.name, @john_smyth.name]
      expect(results.contains_exact_match).to eq true
    end

    it 'puts exact match first for "Alice Andrews"' do
      pending "TODO CT-2691 - commented out test to get ES update working"
      results = search_for('Alice Andrews')
      expect(results.set[0..1].map(&:name)).to eq [@alice.name, @andrew.name]
      expect(results.contains_exact_match).to eq true
    end

    it 'puts exact match first for "Andrew Alice"' do
      results = search_for('Andrew Alice')
      expect(results.set[0..1].map(&:name)).to eq [@andrew.name, @alice.name]
      expect(results.contains_exact_match).to eq true
    end

    it 'puts name synonym matches in results' do
      results = search_for('Abe Kiehn')
      expect(results.set.map(&:name)).to match_array [@abraham_kiehn.name, @abe.name]
      expect(results.contains_exact_match).to eq false
    end

    it 'puts single name match at top of results when name synonym' do
      pending "TODO CT-2691 - commented out test to get ES update working"
      results = search_for('Abe')
      expect(results.set.first.name).to eq @abe.name
      expect(results.contains_exact_match).to eq true
    end

    it 'puts single name match at top of results when first name match' do
      results = search_for('Andrew')
      expect(results.set[0..1].map(&:name)).to eq [@andrew.name, @alice.name]
      expect(results.contains_exact_match).to eq true
    end

    it 'searches by group name and membership role' do
      results = search_for('Director at digiTAL Services')
      expect(results.set.map(&:name)).to include(@bob.name, @john_smyth.name)
      expect(results.contains_exact_match).to eq false
    end

    it 'searches by description, current_project, group and role ' do
      results = search_for('Digital Project')
      expect(results.set.map(&:name)).to include(@bob.name, @john_smyth.name)
      expect(results.contains_exact_match).to eq true
    end

    it 'searches by location' do
      results = search_for('petty france')
      expect(results.set.map(&:name)).to_not include(@alice.name)
      expect(results.set.map(&:name)).to include(@bob.name)
    end

    it 'searches by description, location' do
      results = search_for('weekends only petty france office')
      expect(results.set.map(&:name)).to_not include(@alice.name)
      expect(results.set.map(&:name)).to include(@bob.name)
    end

    it 'searches ignoring * in search term' do
      results = search_for('Alice *')
      expect(results.set.map(&:name)).to include(@alice.name)
      expect(results.contains_exact_match).to eq true
    end

    it 'searches ignoring " at start of search term' do
      results = search_for('"Alice ')
      expect(results.set.map(&:name)).to include(@alice.name)
      expect(results.contains_exact_match).to eq true
    end

    it 'searches ignoring " at end of search term' do
      results = search_for('Alice"')
      expect(results.set.map(&:name)).to include(@alice.name)
      expect(results.contains_exact_match).to eq true
    end

    it 'searches ignoring " in middle of search term' do
      results = search_for('Alice" Andrews')
      expect(results.set.map(&:name)).to include(@alice.name)
      expect(results.contains_exact_match).to eq true
    end

    it 'searches apostrophe in name' do
      results = search_for("O'Leary")
      expect(results.set.first.name).to include(@oleary.name)
      expect(results.contains_exact_match).to eq true

      results = search_for("O’Leary")
      expect(results.set.first.name).to include(@oleary2.name)
      expect(results.contains_exact_match).to eq true
    end

    it 'searches by current project' do
      pending "TODO CT-2691 - commented out test to get ES update working"
      results = search_for('Current project')
      expect(results.set[0..1].map(&:name)).to eq([@bob.name, @alice.name])
      expect(results.contains_exact_match).to eq true
    end

    it 'searches with edit distance of 1' do
      results = search_for("John Collie")
      expect(results.set.first.name).to eql @collier.name
      expect(results.contains_exact_match).to eq false
    end

    it 'searches with edit distance 2 exists' do
      results = search_for("John Colli")
      expect(results.set.first.name).to eq(@collier.name)
      expect(results.contains_exact_match).to eq false
    end

    it 'returns [] for blank search' do
      results = search_for('')
      expect(results.set).to eq([])
      expect(results.contains_exact_match).to eq false
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
          expect(Person.count).to eql 28
          expect(Person.search('*').results.total).to eql 28
        end

        it 'returns person with exact first name and surname in 1st rank' do
          pending "TODO CT-2691 - commented out test to get ES update working"
          expect(results.set.first.name).to eql 'Steve Richards'
        end

        it 'returns people with synonyms of first name and exact surname in 2nd rank' do
          pending "TODO CT-2691 - commented out test to get ES update working"
          expect(results.set[1..2].map(&:name)).to match_array ['Stephen Richards', 'Steven Richards']
        end

        it 'returns people with similar first name or similar surname in 3rd rank' do
          pending "TODO CT-2691 - commented out test to get ES update working"
          expect(results.set[3..7].map(&:name)).to match_array ['John Richards', 'Steve Edmundson', 'Steve Richardson', 'Steven Richardson', 'Stephen Richardson']
        end

        it 'returns people with different and similar combinations' do
          pending "TODO CT-2691 - commented out test to get ES update working"
          expect(results.set[8..-1].map(&:name)).to match_array ['John Richardson', 'Stephen Edmundson']
        end
      end

      context 'search for given name only' do
        let(:query) { 'Steve' }
        let(:expected_steves) { %w(Steve Steven Stephen) }

        it 'returns people in order of given names distance from exact name' do
          pending "TODO CT-2691 - commented out test to get ES update working"
          actual_steves = results.set.map(&:name).map(&:split).map(&:first).uniq
          expect(actual_steves).to match_array expected_steves
          expect(actual_steves.last).to eql expected_steves.last
        end
      end

      context 'search for surname only' do
        let(:query) { 'Richards' }
        let(:expected_richards) { %w(John Steven Stephen Steve) }

        # given name order is unhandled by code
        it 'returns people with only the surname richards in their' do
          actual_richards = results.set.map(&:name).map(&:split).map(&:first).uniq
          expect(actual_richards).to match_array expected_richards
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
