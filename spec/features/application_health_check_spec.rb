require 'feature_helper'

feature 'healthcheck.json' do
  before(:each) do
    allow(Net::SMTP).to receive(:start).and_return('OK')
  end

  scenario 'when there are no errors it should return a 200 code' do
    visit '/healthcheck.json'

    expect(page.status_code).to eq 200
    expect(page).to have_content 'All Components OK'
  end

  scenario 'when there are component errors' do
    allow(ActiveRecord::Base).to receive(:connected?).and_return(false)

    visit '/healthcheck.json'

    expect(page.status_code).to eq 500
    expect(page.body).to match(/Database Error/)
  end
end
