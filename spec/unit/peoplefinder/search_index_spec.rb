require 'rails_helper'
require 'peoplefinder/search_index'

RSpec.describe Peoplefinder::SearchIndex do

  subject(:search_index) { described_class.new }

  let(:digital_services) { create(:group, name: 'Digital Services') }
  let(:design_community) { create(:community, name: "Design") }

  let(:alice) {
    create(:person,
      given_name: 'Alice',
      surname: 'Andrews',
      community: design_community
    )
  }
  let(:bob) {
    create(:person,
      given_name: 'Bob',
      surname: 'Browning',
      location: 'Petty France 10th floor',
      description: 'weekends only'
    ).tap do |bob|
      bob.memberships.create(group: digital_services, role: 'Cleaner')
    end
  }

  describe "updating a person" do
    it "indexes the new params" do
      search_index.index(bob)
      bob.location = "aviation house"
      bob.save!
      search_index.index(bob)

      results = search_index.search("france")
      expect(results).to_not include(bob)

      results = search_index.search("aviation")
      expect(results).to include(bob)
    end
  end

  context 'with some people' do
    before do
      search_index.import([alice, bob])
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
      results = search_index.search('weekends at petty france')
      expect(results).to_not include(alice)
      expect(results).to include(bob)
    end

    it 'searches by community' do
      results = search_index.search(design_community.name)
      expect(results).to include(alice)
      expect(results).to_not include(bob)
    end

    it 'searches by tags' do
      ed = create(:person,
        given_name: 'Edward',
        surname: 'Evans',
        tags: "Cooking,Eating"
      )

      results = search_index.search("cooking")
      expect(results).to include(ed)
    end

    context "with ambiguous matches" do
      let(:charlotte) {
        create(:person,
          given_name: 'Charlotte',
          surname: 'France',
          description: "Working on the Andrews report"
        )
      }

      before do
        search_index.index(charlotte)
      end

      it "ranks name matches above other matches" do
        results = search_index.search('France')
        expect(results).to eq([charlotte, bob])
      end
    end
  end
end
