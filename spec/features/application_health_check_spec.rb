require "rails_helper"

describe "healthcheck.json" do
  before do
    allow(Net::SMTP).to receive(:start).and_return("OK")
  end

  it "when there are no errors it should return a 200 code" do
    visit "/healthcheck.json"

    expect(page.status_code).to eq 200
    expect(page).to have_content({ "checks": { "database": true } }.to_json)
  end

  it "when there are component errors" do
    allow(ActiveRecord::Base.connection).to receive(:execute).and_return(nil)

    visit "/healthcheck.json"

    expect(page.status_code).to eq 500
    expect(page).to have_content({ "checks": { "database": false } }.to_json)
  end
end
