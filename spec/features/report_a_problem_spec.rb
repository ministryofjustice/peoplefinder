require 'rails_helper'

describe 'Report a problem', js: true do
  include ActiveJobHelper
  include PermittedDomainHelper

  before(:all) { Timecop.travel(Time.at(1_410_298_020)) }

  after(:all) { Timecop.return }

  before do
    ActionMailer::Base.deliveries.clear
  end

  context 'when logged in' do
    let(:me) { create(:person) }
    let(:group) { create(:group) }

    before do
      token_log_in_as(me.email)
    end

    it 'Reporting a problem', js: true do
      visit group_path(group)

      click_link 'Report a problem' # includes a wait, which is required for the slideToggle jquery behaviour
      fill_in 'What were you trying to do?', with: 'Rhubarb'
      fill_in 'What went wrong?', with: 'Custard'
      expect { click_button 'Report' }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(page).to have_current_path group_path(group), ignore_query: true
      expect(last_email.to).to eq([Rails.configuration.support_email])
      body = last_email.body.encoded

      expect(body).to have_text('Rhubarb')
      expect(body).to have_text('Custard')
      expect(body).to match(/Browser: .*?Mozilla/)
      expect(body).to have_text("Email: #{me.email}")
      expect(body).to have_text("Person ID: #{me.id}")
      expect(body).to match(/Reported: 2014-09-09T21:27:..Z/)
    end
  end

  context 'when not logged in' do
    it 'Reporting a problem', js: true do
      visit new_sessions_path

      click_link 'Report a problem' # includes a wait, which is required for the slideToggle jquery behaviour
      fill_in 'What were you trying to do?', with: 'Rhubarb'
      fill_in 'What went wrong?', with: 'Custard'
      fill_in 'Your email', with: 'test@example.com'
      expect { click_button 'Report' }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(page).to have_current_path(new_sessions_path, ignore_query: true)

      expect(last_email.to).to eq([Rails.configuration.support_email])
      body = last_email.body.encoded

      expect(body).to have_text('Rhubarb')
      expect(body).to have_text('Custard')
      expect(body).to match(/Browser: .*?Mozilla/)
      expect(body).to have_text('Email: test@example.com')
      expect(body).to have_text('Person ID: unknown')
      expect(body).to match(/Reported: 2014-09-09T21:27:..Z/)
    end
  end
end
