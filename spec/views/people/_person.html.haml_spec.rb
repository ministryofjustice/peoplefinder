require 'rails_helper'

RSpec.describe "rendering locals in a partial" do
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
    people.each_with_index {|p, i| teams[i].people << p}
    people
  end

  before do
    render partial: 'people/person', collection: people, locals: { edit_link: false }
  end

  shared_examples 'sets analytics attributes' do
    it "sets data-virtual-pageview correctly on links" do
      expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/top-3-search-result"]', text: list[0].send(label))
      expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/top-3-search-result"]', text: list[1].send(label))
      expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/top-3-search-result"]', text: list[2].send(label))
      expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/below-top-3-search-result"]', text: list[3].send(label))
    end

    it "sets data-event-category correctly on links" do
      list.each do |item|
        expect(rendered).to have_selector('[data-event-category="Search result click"]', text: item.send(label))
      end
    end

    it "sets data-event-action correctly on links" do
      expect(rendered).to have_selector('[data-event-action="Click result 001"]', text: list[0].send(label))
      expect(rendered).to have_selector('[data-event-action="Click result 002"]', text: list[1].send(label))
      expect(rendered).to have_selector('[data-event-action="Click result 003"]', text: list[2].send(label))
      expect(rendered).to have_selector('[data-event-action="Click result 004"]', text: list[3].send(label))
    end
  end

  describe 'people links' do
    let(:list) { people }
    let(:label) { :name }

    include_examples 'sets analytics attributes'
  end

  describe 'team links' do
    let(:list) { teams }
    let(:label) { :name }

    include_examples 'sets analytics attributes'
  end

end