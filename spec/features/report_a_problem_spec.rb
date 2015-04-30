require 'rails_helper'

feature 'Report a problem', js: true do
  include ActiveJobHelper
  include PermittedDomainHelper

  let(:current_time) { Time.at(1_410_298_077) }

  around do |example|
    Timecop.travel(current_time)
    example.run
    Timecop.return
  end

  context 'When logged in' do
    let(:me) { create(:person) }
    let(:group) { create(:group) }

    before do
      omni_auth_log_in_as(me.email)
      javascript_log_in
    end

    scenario 'Reporting a problem' do
      visit group_path(group)

      find('a', text: 'Report a problem').trigger('click')
      fill_in 'What were you trying to do?', with: 'Rhubarb'
      fill_in 'What went wrong?', with: 'Custard'
      click_button 'Report'

      expect(current_path).to eq(group_path(group))

      expect(last_email.to).to eq([Rails.configuration.support_email])
      body = last_email.body.encoded

      expect(body).to have_text('Rhubarb')
      expect(body).to have_text('Custard')
      expect(body).to match(/Browser: .*?PhantomJS/)
      expect(body).to have_text("Email: #{me.email}")
      expect(body).to have_text("Person ID: #{me.id}")
      expect(body).to match(/Reported: 2014-09-09T21:27:..Z/)
    end
  end

  context 'When not logged in' do
    scenario 'Reporting a problem' do
      visit new_sessions_path

      find('a', text: 'Report a problem').trigger('click')
      fill_in 'What were you trying to do?', with: 'Rhubarb'
      fill_in 'What went wrong?', with: 'Custard'
      click_button 'Report'

      expect(current_path).to eq(new_sessions_path)

      expect(last_email.to).to eq([Rails.configuration.support_email])
      body = last_email.body.encoded

      expect(body).to have_text('Rhubarb')
      expect(body).to have_text('Custard')
      expect(body).to match(/Browser: .*?PhantomJS/)
      expect(body).to have_text('Email: unknown')
      expect(body).to have_text('Person ID: unknown')
      expect(body).to match(/Reported: 2014-09-09T21:27:..Z/)
    end
  end
end
