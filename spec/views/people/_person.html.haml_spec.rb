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

  it "sets data-virtual-pageview correctly on people links" do
    expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/top-3-search-result"]', text: people[0].name)
    expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/top-3-search-result"]', text: people[1].name)
    expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/top-3-search-result"]', text: people[2].name)
    expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/below-top-3-search-result"]', text: people[3].name)
  end

  it "sets data-virtual-pageview correctly on team links" do
    expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/top-3-search-result"]', text: teams[0].name)
    expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/top-3-search-result"]', text: teams[1].name)
    expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/top-3-search-result"]', text: teams[2].name)
    expect(rendered).to have_selector('[data-virtual-pageview="/search-result,/below-top-3-search-result"]', text: teams[3].name)
  end

  it "sets data-event-category correctly" do
    expect(rendered).to have_selector('[data-event-category="Search result click"]', text: people[0].name)
    expect(rendered).to have_selector('[data-event-category="Search result click"]', text: people[1].name)
    expect(rendered).to have_selector('[data-event-category="Search result click"]', text: people[2].name)
    expect(rendered).to have_selector('[data-event-category="Search result click"]', text: people[3].name)
  end

  it "sets data-event-action correctly" do
    expect(rendered).to have_selector('[data-event-action="Click result 001"]', text: people[0].name)
    expect(rendered).to have_selector('[data-event-action="Click result 002"]', text: people[1].name)
    expect(rendered).to have_selector('[data-event-action="Click result 003"]', text: people[2].name)
    expect(rendered).to have_selector('[data-event-action="Click result 004"]', text: people[3].name)
  end
end