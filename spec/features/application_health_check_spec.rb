require "rails_helper"

describe "healthcheck.json" do
  before do
    allow(Net::SMTP).to receive(:start).and_return("OK")
    allow(::Elasticsearch::Model.client.cluster).to receive(:health).and_return("status" => "green")
  end

  it "when there are no errors it should return a 200 code" do
    visit "/healthcheck.json"

    expect(page.status_code).to eq 200
    expect(page).to have_content "All Components OK"
  end

  it "when there are component errors" do
    allow(ActiveRecord::Base.connection).to receive(:active?).and_return(false)

    visit "/healthcheck.json"

    expect(page.status_code).to eq 500
    expect(page.body).to match(/Database Error/)
  end
end
