require "rails_helper"
require_relative "shared_examples_for_search"

RSpec.describe PersonSearch do

  let!(:group) { create(:group, name: "Digital Services") }

  before do
    create(:permitted_domain, domain: "example.com")
  end

  def make_person(given_name:, surname:, **attrs)
    create(:person, :member_of, team: group, sole_membership: true,
                                given_name:, surname:, email: "#{given_name.downcase}.#{surname.downcase}@example.com",
                                **attrs)
  end

  def search(query)
    described_class.new(query, SearchResults.new).perform_search
  end

  it_behaves_like "a search"

  describe "#perform_search" do
    let!(:jon_browne) { make_person(given_name: "Jon", surname: "Browne") }
    let!(:jane_smith) { make_person(given_name: "Jane", surname: "Smith") }

    it "returns empty results for blank query" do
      expect(search("").set).to be_empty
    end

    it "finds people by surname" do
      expect(search("Browne").set).to include(jon_browne)
      expect(search("Browne").set).not_to include(jane_smith)
    end

    it "finds people by given name" do
      expect(search("Jon").set).to include(jon_browne)
    end

    it "finds people by full name" do
      expect(search("Jon Browne").set).to include(jon_browne)
    end

    it "is case-insensitive" do
      expect(search("browne").set).to include(jon_browne)
      expect(search("BROWNE").set).to include(jon_browne)
    end

    it "finds by exact email match" do
      result = search("jon.browne@example.com")
      expect(result.set).to include(jon_browne)
      expect(result.contains_exact_match).to be true
    end

    it "finds people by current project" do
      make_person(given_name: "Alice", surname: "Project", current_project: "Operation Phoenix")
      expect(search("Operation Phoenix").set.map(&:surname)).to include("Project")
    end

    it "finds people by group name" do
      expect(search("Digital Services").set).to include(jon_browne)
    end

    it "returns results ordered with best match first" do
      results = search("Jon Browne").set
      expect(results.first).to eq jon_browne
    end

    it "finds synonyms (tony → anthony)" do
      anthony = make_person(given_name: "Anthony", surname: "Jones")
      results = search("tony jones").set
      expect(results).to include(anthony)
    end

    it "handles fuzzy matching for typos" do
      results = search("Brwone").set
      expect(results).to include(jon_browne)
    end

    it "sets exact_match true for single-word query with results" do
      result = search("Browne")
      expect(result.contains_exact_match).to be true
    end

    it "sets exact_match true for multi-word query where full name matches" do
      result = search("Jon Browne")
      expect(result.contains_exact_match).to be true
    end

    it "sets exact_match false for multi-word query with no full-name match" do
      result = search("Jon Smith")
      expect(result.contains_exact_match).to be false
    end

    it "provides hit objects for highlighting" do
      result = search("Jon")
      result.each_with_hit do |person, hit|
        next unless person == jon_browne

        expect(hit).not_to be_nil
        expect(hit.highlight.name).to be_an(Array)
        expect(hit.highlight.name.first).to include("es-highlight")
      end
    end
  end
end
