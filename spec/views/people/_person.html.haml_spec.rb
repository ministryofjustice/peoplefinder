require 'rails_helper'

RSpec.describe "rendering locals in a partial" do

  let(:people) do
    [
      build(:person, given_name: "A"),
      build(:person, given_name: "B"),
      build(:person, given_name: "C"),
      build(:person, given_name: "D")
    ]
  end

  before do
    render partial: 'people/person', collection: people, locals: { edit_link: false }
  end

  it "sets data-virtual-pageview correctly" do
    expect(rendered).to have_selector('[data-virtual-pageview="/top-3-search-result"]', text: people[0].name)
    expect(rendered).to have_selector('[data-virtual-pageview="/top-3-search-result"]', text: people[1].name)
    expect(rendered).to have_selector('[data-virtual-pageview="/top-3-search-result"]', text: people[2].name)
    expect(rendered).to have_selector('[data-virtual-pageview="/below-top-3-search-result"]', text: people[3].name)
  end

  it "sets data-event-category correctly" do
    expect(rendered).to have_selector('[data-event-category="Search result"]', text: people[0].name)
    expect(rendered).to have_selector('[data-event-category="Search result"]', text: people[1].name)
    expect(rendered).to have_selector('[data-event-category="Search result"]', text: people[2].name)
    expect(rendered).to have_selector('[data-event-category="Search result"]', text: people[3].name)
  end

  it "sets data-event-action correctly" do
    expect(rendered).to have_selector('[data-event-action="Click result 1"]', text: people[0].name)
    expect(rendered).to have_selector('[data-event-action="Click result 2"]', text: people[1].name)
    expect(rendered).to have_selector('[data-event-action="Click result 3"]', text: people[2].name)
    expect(rendered).to have_selector('[data-event-action="Click result 4"]', text: people[3].name)
  end
end