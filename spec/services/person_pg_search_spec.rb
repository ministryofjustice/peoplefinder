require "rails_helper"

RSpec.describe PersonPgSearch do
  include PermittedDomainHelper

  let(:results) { PgSearchResults.new }

  def search(query)
    described_class.new(query, results).perform_search
  end

  def result_set(query)
    search(query).set
  end

  describe "#perform_search" do
    it "returns the supplied PgSearchResults instance" do
      expect(described_class.new("", results).perform_search).to be results
    end

    context "when query is blank" do
      it "returns an empty set" do
        create(:person, given_name: "Alice", surname: "Smith")
        expect(result_set("")).to be_empty
      end

      it "does not set contains_exact_match" do
        expect(search("").contains_exact_match).to be false
      end
    end

    context "when query matches an email address" do
      let(:person) { create(:person, given_name: "Alice", surname: "Smith") }

      it "finds by exact email" do
        expect(result_set(person.email)).to include(person)
      end

      it "is case-insensitive" do
        expect(result_set(person.email.upcase)).to include(person)
      end

      it "sets contains_exact_match true" do
        expect(search(person.email).contains_exact_match).to be true
      end
    end

    context "with name queries" do
      let!(:alice)   { create(:person, given_name: "Alice",   surname: "Smith") }
      let!(:bob)     { create(:person, given_name: "Bob",     surname: "Smith") }
      let!(:charlie) { create(:person, given_name: "Charlie", surname: "Jones") }

      it "finds by exact given name" do
        expect(result_set("Alice")).to include(alice)
      end

      it "finds by exact surname" do
        expect(result_set("Smith")).to include(alice, bob)
      end

      it "finds by full name" do
        set = result_set("Alice Smith")
        expect(set).to include(alice)
        expect(set).not_to include(charlie)
      end

      it "is case-insensitive" do
        expect(result_set("alice smith")).to include(alice)
        expect(result_set("ALICE SMITH")).to include(alice)
      end

      it "ignores non-alphanumeric characters in query" do
        expect(result_set("Alice, Smith!")).to include(alice)
      end

      it "returns empty when no name matches" do
        expect(result_set("Zephyr Xylophone")).to be_empty
      end

      it "handles LIKE special characters without error" do
        expect { result_set("100%") }.not_to raise_error
        expect { result_set("first_name") }.not_to raise_error
        expect { result_set('back\slash') }.not_to raise_error
      end
    end

    context "with fuzzy / trigram matching" do
      it "finds a person despite a typo in the given name" do
        person = create(:person, given_name: "Jonathan", surname: "Smith")
        expect(result_set("Jonathon")).to include(person)
      end

      it "finds a person despite a typo in the surname" do
        person = create(:person, given_name: "Alice", surname: "Robertson")
        expect(result_set("Robertsun")).to include(person)
      end
    end

    context "with synonym expansion" do
      it "finds David when searching for Dave" do
        david = create(:person, given_name: "David", surname: "Brown")
        expect(result_set("Dave Brown")).to include(david)
      end

      it "finds Dave when searching for David (synonym is bidirectional)" do
        dave = create(:person, given_name: "Dave", surname: "Green")
        expect(result_set("David Green")).to include(dave)
      end
    end

    context "with role and group queries" do
      let!(:department) { create(:department, name: "Finance") }
      let!(:team)       { create(:group, name: "Payroll Team", parent: department) }
      let!(:person)     { create(:person, :member_of, team:, given_name: "Carol", surname: "White") }

      before do
        person.memberships.find_by!(group: team).update!(role: "Senior Analyst")
      end

      it "finds by team name" do
        expect(result_set("Payroll Team")).to include(person)
      end

      it "finds by role" do
        expect(result_set("Senior Analyst")).to include(person)
      end
    end

    context "with other field queries" do
      let!(:person) do
        create(:person,
               given_name: "Eve",
               surname: "Hall",
               current_project: "Project Aurora",
               description: "Expert in quantum mechanics",
               building: "Here Building",
               city: "Here City")
      end

      it "finds by current_project" do
        expect(result_set("Project Aurora")).to include(person)
      end

      it "finds by description" do
        expect(result_set("quantum mechanics")).to include(person)
      end

      it "finds by city" do
        expect(result_set("Here City")).to include(person)
      end
    end

    context "with ranking" do
      let!(:name_match) { create(:person, given_name: "Aurora", surname: "Blake") }
      let!(:desc_match) { create(:person, given_name: "Bertrand", surname: "Zork", description: "aurora borealis expert") }

      it "ranks name matches above description matches" do
        set = result_set("Aurora")
        expect(set).to include(name_match), "Aurora Blake should be found by given name"
        expect(set).to include(desc_match), "Bertrand Zork should be found by description"
        expect(set.index(name_match)).to be < set.index(desc_match)
      end
    end

    context "with contains_exact_match flag" do
      let(:person) { create(:person, given_name: "Frank", surname: "Castle") }

      before do
        person
      end

      it "is true when searching a single word that returns results" do
        expect(search("Frank").contains_exact_match).to be true
      end

      it "is true when the full name matches exactly" do
        expect(search("Frank Castle").contains_exact_match).to be true
      end

      it "is false for a multi-word query with no exact name match and no partial field match" do
        expect(search("Frank Nonexistent").contains_exact_match).to be false
      end

      it "is false when there are no results" do
        expect(search("Nonexistent Person").contains_exact_match).to be false
      end
    end

    context "with result limit" do
      it "returns at most MAX_RESULTS people" do
        create_list(:person, described_class::MAX_RESULTS + 5, given_name: "Zara", surname: "Common")
        expect(result_set("Zara Common").size).to eq described_class::MAX_RESULTS
      end
    end
  end

  describe ".synonyms_for" do
    it "returns synonyms for a known nickname" do
      expect(described_class.synonyms_for("dave")).to include("david")
    end

    it "returns an empty array for an unknown word" do
      expect(described_class.synonyms_for("zxqfoo")).to eq []
    end

    it "is case-insensitive" do
      expect(described_class.synonyms_for("Dave")).to eq described_class.synonyms_for("dave")
    end
  end

  describe "with Hit highlight" do
    let(:person) { create(:person, given_name: "Alice", surname: "Smith") }

    it "wraps the matched term in a highlight span" do
      pattern = /alice/i
      hit = described_class::Hit.new(person, pattern)
      expect(hit.highlight.name.first).to include('<span class="es-highlight">Alice</span>')
    end

    it "returns nil when the field does not match the pattern" do
      pattern = /zzznomatch/i
      hit = described_class::Hit.new(person, pattern)
      expect(hit.highlight.name).to be_nil
    end
  end
end
