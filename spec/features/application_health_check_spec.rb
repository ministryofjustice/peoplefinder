require "rails_helper"

describe "healthcheck.json" do
  before do
    allow(Net::SMTP).to receive(:start).and_return("OK")
    allow(::OpenSearch::Model.client.cluster).to receive(:health).and_return("status" => "green")
  end

  it "when there are no errors it should return a 200 code" do
    visit "/healthcheck.json"

    expect(page.status_code).to eq 200
    expect(page).to have_content({ "checks": { "database": true, "search": true } }.to_json)
  end

  it "when there are component errors" do
    allow(ActiveRecord::Base.connection).to receive(:active?).and_return(false)

    visit "/healthcheck.json"

    expect(page.status_code).to eq 503
    expect(page).to have_content({ "checks": { "database": false, "search": true } }.to_json)
  end
end
