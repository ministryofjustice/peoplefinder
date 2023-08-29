require "rails_helper"

RSpec.describe "search/person", type: :view do
  include PermittedDomainHelper

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    clean_up_indexes_and_tables
    PermittedDomain.find_or_create_by!(domain: "digital.justice.gov.uk")
    create_list(:group, 4).each do |team|
      create(:person, :member_of, team:, sole_membership: true)
    end
    Person.import force: true
    Person.__opensearch__.refresh_index!
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    clean_up_indexes_and_tables
  end

  let(:people_results) do
    Person.search(match_all).records
  end

  before do
    controller.singleton_class.class_eval do
      def current_user
        Person.first
      end
      helper_method :current_user
    end

    people_results.each_with_hit.with_index do |(person, hit), idx|
      render partial: "search/person", locals: { person:, hit:, index: idx, current_user: controller.current_user }
    end
  end

  shared_examples "sets analytics attributes" do
    it "sets data-event-category correctly on links" do
      list.each do |item|
        expect(rendered).to have_selector('[data-event-category="Search result click"]', text: item)
      end
    end

    it "sets data-event-action correctly on links" do
      list.each.with_index do |item, idx|
        expect(rendered).to have_selector("[data-event-action=\"Click result 00#{idx + 1}\"]", text: item)
      end
    end

    it "sets data-virtual-pageview correctly on links" do
      expect(rendered).to have_selector(".#{div} [data-virtual-pageview=\"/search-result,/top-3-search-result\"]", count: 3)
      expect(rendered).to have_selector(".#{div} [data-virtual-pageview=\"/search-result,/below-top-3-search-result\"]", count: 1)
    end
  end

  describe "people links" do
    let(:list) { people_results.map(&:name) }
    let(:div) { "cb-person-name" }

    include_examples "sets analytics attributes"
  end

  describe "team links" do
    let(:div) { "cb-person-memberships" }
    let(:list) do
      people_results.map { |person|
        person.memberships.map do |membership|
          membership.group.name
        end
      }.flatten
    end

    include_examples "sets analytics attributes"
  end

  describe "email links" do
    let(:div) { "cb-person-email" }
    let(:list) { people_results.map(&:email) }

    include_examples "sets analytics attributes"
  end
end
