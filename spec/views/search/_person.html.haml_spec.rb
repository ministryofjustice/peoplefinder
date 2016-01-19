require 'rails_helper'

RSpec.describe 'search/person' do
  include PermittedDomainHelper

  let(:teams) do
    [
      create(:group),
      create(:group),
      create(:group),
      create(:group)
    ]
  end

  let(:people) do
    people = [
      create(:person),
      create(:person),
      create(:person),
      create(:person)
    ]
    people.each_with_index { |p, i| teams[i].people << p }
    people
  end

  before do
    render partial: 'search/person', collection: people, locals: { search_result: true }
  end

  shared_examples 'sets analytics attributes' do
    it "sets data-virtual-pageview correctly on links" do
      expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/top-3-search-result"]', text: list[0])
      expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/top-3-search-result"]', text: list[1])
      expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/top-3-search-result"]', text: list[2])
      expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/below-top-3-search-result"]', text: list[3])
    end

    it "sets data-event-category correctly on links" do
      list.each do |item|
        expect(rendered).to have_selector('[data-event-category="Search result click"]', text: item)
      end
    end

    it "sets data-event-action correctly on links" do
      expect(rendered).to have_selector('[data-event-action="Click result 001"]', text: list[0])
      expect(rendered).to have_selector('[data-event-action="Click result 002"]', text: list[1])
      expect(rendered).to have_selector('[data-event-action="Click result 003"]', text: list[2])
      expect(rendered).to have_selector('[data-event-action="Click result 004"]', text: list[3])
    end
  end

  describe 'people links' do
    let(:list) { people.map(&:name) }

    include_examples 'sets analytics attributes'
  end

  describe 'team links' do
    let(:list) { teams.map(&:name) }

    include_examples 'sets analytics attributes'
  end

  describe 'email links' do
    let(:list) { people.map(&:email) }

    include_examples 'sets analytics attributes'
  end

end
