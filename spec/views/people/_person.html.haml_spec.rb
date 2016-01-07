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

  it "sets data-virtual-pageview correctly" do
    render partial: 'people/person', collection: people, locals: { edit_link: false }

    expect(rendered).to have_selector('[data-virtual-pageview="/top-3-search-result"]', text: people[0].name)
    expect(rendered).to have_selector('[data-virtual-pageview="/top-3-search-result"]', text: people[1].name)
    expect(rendered).to have_selector('[data-virtual-pageview="/top-3-search-result"]', text: people[2].name)
    expect(rendered).to have_selector('[data-virtual-pageview="/below-top-3-search-result"]', text: people[3].name)
  end
end